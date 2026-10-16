#!/usr/bin/env bash
# Scheduled harness review: runs the swe-harness-review skill unattended so lessons logged in
# projects' docs/HARNESS-FEEDBACK.md become skill fixes sent to the owner for approval.
# Works for projects that live only on this computer and for projects on GitHub.
#
# Usage:
#   scripts/harness-review.sh run [--now]   # review if due (every 7 days) and feedback changed; --now forces it
#   scripts/harness-review.sh schedule      # check daily: Windows Task Scheduler on WSL, cron elsewhere
#   scripts/harness-review.sh unschedule
#   scripts/harness-review.sh status
#
# Settings (environment): SWE_REVIEW_AGENT=claude|pi|copilot (default: first one installed),
#   SWE_REVIEW_CMD='my-agent -p "$PROMPT"' (custom), SWE_REVIEW_EVERY_DAYS=7,
#   SWE_PROJECT_ROOTS=~/dev:~/work (where to look for projects), SWE_STATE_DIR=~/.swe-orchestrator
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${SWE_STATE_DIR:-$HOME/.swe-orchestrator}"
LOG_DIR="$STATE_DIR/logs"
EVERY_DAYS="${SWE_REVIEW_EVERY_DAYS:-7}"
TASK_NAME="SWE Harness Review"
CRON_TAG="# swe-harness-review"
PROMPT="Use the swe-harness-review skill. This is a scheduled, unattended run: do not ask questions or wait for input. Collect new harness feedback from all projects (local and GitHub) and, if there are new lessons, prepare the improvements and deliver them for the owner's approval as the skill describes."

# Scheduled runs get a minimal PATH; add the usual places agents and node live.
for d in "$HOME/.local/bin" "$HOME/.npm-global/bin" "$HOME/.bun/bin" "$HOME/.cargo/bin" /usr/local/bin \
         "$HOME"/.nvm/versions/node/*/bin "$HOME/.kimi-code/bin"; do
  [[ -d "$d" && ":$PATH:" != *":$d:"* ]] && PATH="$PATH:$d"
done
export PATH

mkdir -p "$LOG_DIR"
log() { printf '%s %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG_DIR/harness-review.log"; }

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }
win_ps() { command -v powershell.exe 2>/dev/null || echo /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe; }
ps_run() { (cd /mnt/c && "$(win_ps)" -NoProfile -Command "$1" 2>&1 | tr -d '\r'); }

project_roots() {
  local IFS=':;' r
  for r in ${SWE_PROJECT_ROOTS:-$HOME/dev}; do [[ -d "$r" ]] && echo "$r"; done
  [[ -f "$STATE_DIR/projects.tsv" ]] && cut -f1 "$STATE_DIR/projects.tsv" | while IFS= read -r p; do [[ -d "$p" ]] && echo "$p"; done
  return 0
}

feedback_files() {
  project_roots | sort -u | while IFS= read -r r; do
    # skip the harness repo itself: its copy of the file is the template
    find "$r" -maxdepth 5 \( -name node_modules -o -name .git -o -path "$REPO_DIR" \) -prune -o -path '*/docs/HARNESS-FEEDBACK.md' -print 2>/dev/null
  done | sort -u
}

sha() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$@"; else shasum -a 256 "$@"; fi; }

gh_ok() { command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; }

# A fingerprint of all feedback, local and on GitHub, so we only start an agent when something changed.
fingerprint() {
  {
    feedback_files | while IFS= read -r f; do sha "$f"; done
    if gh_ok; then
      local me; me="$(gh api user --jq .login 2>/dev/null || true)"
      [[ -n "$me" ]] && gh search code --owner "$me" --filename HARNESS-FEEDBACK.md --json repository,sha \
        --jq '.[] | "\(.sha) gh:\(.repository.nameWithOwner)"' 2>/dev/null || true
    fi
  } | sort | sha | cut -d' ' -f1
}

pick_agent() {
  if [[ -n "${SWE_REVIEW_CMD:-}" ]]; then echo custom; return; fi
  if [[ -n "${SWE_REVIEW_AGENT:-}" ]]; then echo "$SWE_REVIEW_AGENT"; return; fi
  local a; for a in claude pi copilot; do command -v "$a" >/dev/null 2>&1 && { echo "$a"; return; }; done
  echo none
}

run_agent() { # <agent>
  local -a extra=()
  local r
  while IFS= read -r r; do extra+=(--add-dir "$r"); done < <(project_roots | sort -u)
  case "$1" in
    claude)
      claude -p "$PROMPT" --permission-mode acceptEdits --add-dir "$STATE_DIR" ${extra[@]+"${extra[@]}"} \
        --allowedTools Read Edit Write Glob Grep "Bash(git:*)" "Bash(gh:*)" "Bash(find:*)" "Bash(ls:*)" \
          "Bash(cat:*)" "Bash(head:*)" "Bash(grep:*)" "Bash(mkdir:*)" "Bash(date:*)" "Bash(bash -n:*)" "Bash(sha256sum:*)" "Bash(shasum:*)" ;;
    pi)      pi -p "$PROMPT" ;;
    copilot) copilot -p "$PROMPT" --allow-all-tools ;;
    custom)  PROMPT="$PROMPT" bash -c "$SWE_REVIEW_CMD" ;;
    *) log "no supported agent found (claude, pi, copilot); set SWE_REVIEW_AGENT or SWE_REVIEW_CMD"; return 1 ;;
  esac
}

cmd_run() {
  local force=0; [[ "${1:-}" == --now ]] && force=1
  local now last fp lastfp agent out
  now="$(date +%s)"; last="$(cat "$STATE_DIR/last-review-run" 2>/dev/null || echo 0)"
  if ((!force)) && (( now - last < EVERY_DAYS * 86400 )); then exit 0; fi   # not due; stay quiet

  fp="$(fingerprint)"; lastfp="$(cat "$STATE_DIR/last-review-fingerprint" 2>/dev/null || true)"
  if ((!force)) && [[ "$fp" == "$lastfp" ]]; then
    log "no new harness feedback; nothing to review"; echo "$now" > "$STATE_DIR/last-review-run"; exit 0
  fi
  if [[ -n "$(git -C "$REPO_DIR" status --porcelain)" ]]; then
    log "skipped: the harness repo has uncommitted changes; will retry tomorrow"; exit 0
  fi

  agent="$(pick_agent)"
  out="$LOG_DIR/review-$(date +%F).log"
  log "starting harness review with $agent (output: $out)"
  local -a tmo=(); command -v timeout >/dev/null 2>&1 && tmo=(timeout 2h)
  if (cd "$REPO_DIR" && ${tmo[@]+"${tmo[@]}"} "$REPO_DIR/scripts/harness-review.sh" __agent "$agent") >>"$out" 2>&1; then
    echo "$now" > "$STATE_DIR/last-review-run"; echo "$fp" > "$STATE_DIR/last-review-fingerprint"
    log "harness review finished"
  else
    log "harness review failed (see $out); will retry tomorrow"; exit 1
  fi
}

cmd_schedule() {
  local self="$REPO_DIR/scripts/harness-review.sh"
  if is_wsl && [[ -x "$(win_ps)" ]]; then
    # distro name, e.g. Ubuntu; fall back to parsing \\wsl.localhost\<distro>\ when the variable isn't set
    local distro="${WSL_DISTRO_NAME:-$(wslpath -w / 2>/dev/null | sed -E 's#^\\\\wsl(\.localhost|\$)?\\([^\\]+).*#\2#')}"
    [[ -n "$distro" && "$distro" != *\\* ]] || { echo "can't tell which WSL distribution this is; run this from a WSL shell" >&2; exit 1; }
    ps_run "\$a = New-ScheduledTaskAction -Execute 'wsl.exe' -Argument '-d $distro -- bash -lc \"''$self'' run\"';
      \$t = New-ScheduledTaskTrigger -Daily -At 10:00;
      \$s = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 3);
      Register-ScheduledTask -TaskName '$TASK_NAME' -Description 'Weekly review of harness feedback (SWE Orchestrator). Checks daily, runs at most every $EVERY_DAYS days.' -Action \$a -Trigger \$t -Settings \$s -Force | Out-Null;
      'scheduled in Windows Task Scheduler: $TASK_NAME (daily check at 10:00, catches up if the PC was off)'"
  elif command -v crontab >/dev/null 2>&1; then
    local line="17 10 * * * bash -lc '\"$self\" run' >> \"$LOG_DIR/cron.log\" 2>&1 $CRON_TAG"
    { crontab -l 2>/dev/null | grep -v "$CRON_TAG" || true; echo "$line"; } | crontab -
    echo "scheduled with cron (daily check at 10:17; runs at most every $EVERY_DAYS days, catches up on the next check)"
  else
    echo "No scheduler found (Windows Task Scheduler or cron). Run '$self run' yourself now and then." >&2; exit 1
  fi
}

cmd_unschedule() {
  if is_wsl && [[ -x "$(win_ps)" ]]; then
    ps_run "if (Get-ScheduledTask -TaskName '$TASK_NAME' -ErrorAction SilentlyContinue) { Unregister-ScheduledTask -TaskName '$TASK_NAME' -Confirm:\$false; 'removed from Windows Task Scheduler' } else { 'not scheduled' }"
  fi
  if command -v crontab >/dev/null 2>&1 && crontab -l 2>/dev/null | grep -q "$CRON_TAG"; then
    crontab -l | grep -v "$CRON_TAG" | crontab -; echo "removed from cron"
  fi
}

cmd_status() {
  local sched="not scheduled"
  if is_wsl && [[ -x "$(win_ps)" ]]; then
    [[ "$(ps_run "[bool](Get-ScheduledTask -TaskName '$TASK_NAME' -ErrorAction SilentlyContinue)")" == True ]] && sched="Windows Task Scheduler"
  fi
  command -v crontab >/dev/null 2>&1 && crontab -l 2>/dev/null | grep -q "$CRON_TAG" && sched="cron"
  local last; last="$(cat "$STATE_DIR/last-review-run" 2>/dev/null || true)"
  echo "Schedule:        $sched"
  if [[ -n "$last" && "$last" != 0 ]]; then last="$(date -d "@$last" '+%F %R' 2>/dev/null || date -r "$last" '+%F %R')"; else last=never; fi
  echo "Last review:     $last"
  echo "Review agent:    $(pick_agent)"
  echo "GitHub:          $(gh_ok && echo "connected (GitHub projects included)" || echo "not connected (local projects only)")"
  echo "Feedback files:  $(feedback_files | wc -l | tr -d ' ') local"
  local waiting; waiting="$( (grep -l '^Status: waiting for owner' "$STATE_DIR"/reports/*.md 2>/dev/null || true) | wc -l | tr -d ' ')"
  echo "Waiting reviews: $waiting (reports in $STATE_DIR/reports)"
}

case "${1:-status}" in
  run) shift; cmd_run "$@" ;;
  schedule) cmd_schedule ;;
  unschedule) cmd_unschedule ;;
  status) cmd_status ;;
  __agent) run_agent "$2" ;;   # internal: lets `timeout` wrap the agent call
  -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//' ;;
  *) echo "unknown command: $1 (try --help)" >&2; exit 1 ;;
esac
