#!/usr/bin/env bash
# SWE Orchestrator Skills installer
# Installs the swe-* skills into Claude Code, GitHub Copilot CLI, Antigravity, Kimi Code, pi and Cursor,
# plus the toolbox packs (obra/superpowers, addyosmani/agent-skills subset).
# Inside WSL it also runs install.ps1 for the Windows versions of those agents (skip with --no-windows).
# On Windows without WSL, use install.ps1 instead.
#
# Usage:
#   ./install.sh [install] [--dry-run] [--skip-superpowers] [--skip-addy] [--no-windows] [--agents=claude,copilot,antigravity,kimi,pi,cursor]
#   ./install.sh init <project-dir> [--dry-run]     # scaffold docs/ + AGENTS.md in a project
#   ./install.sh update [--dry-run]                  # git pull this repo, re-link skills, refresh toolbox packs
#   ./install.sh status                              # show what is installed where
#   ./install.sh uninstall [--dry-run]               # remove our skill symlinks (toolbox packs left alone)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
TEMPLATES="$SKILLS_SRC/swe-orchestrator/templates"

ADDY_SKILLS=(security-and-hardening ci-cd-and-automation observability-and-instrumentation
  shipping-and-launch documentation-and-adrs api-and-interface-design
  performance-optimization frontend-ui-engineering)

DRY_RUN=0 SKIP_SP=0 SKIP_ADDY=0 NO_WINDOWS=0 AGENTS_FILTER="" CMD="install" INIT_DIR=""

c_green=$'\e[32m' c_yellow=$'\e[33m' c_red=$'\e[31m' c_dim=$'\e[2m' c_off=$'\e[0m'
info() { printf '%s\n' "${c_green}==>${c_off} $*"; }
warn() { printf '%s\n' "${c_yellow}!!${c_off} $*" >&2; }
err()  { printf '%s\n' "${c_red}xx${c_off} $*" >&2; }
run()  {
  if ((DRY_RUN)); then printf '%s\n' "${c_dim}[dry-run]${c_off} $*"; return 0; fi
  "$@"
}

for arg in "$@"; do
  case "$arg" in
    install|update|status|uninstall|init) CMD="$arg" ;;
    --dry-run) DRY_RUN=1 ;;
    --skip-superpowers) SKIP_SP=1 ;;
    --skip-addy) SKIP_ADDY=1 ;;
    --no-windows) NO_WINDOWS=1 ;;
    --agents=*) AGENTS_FILTER="${arg#--agents=}" ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) err "Unknown option: $arg"; exit 1 ;;
    *) if [[ "$CMD" == init && -z "$INIT_DIR" ]]; then INIT_DIR="$arg"; else err "Unexpected argument: $arg"; exit 1; fi ;;
  esac
done

# ---------- agent detection ----------
# Windows user folder (as a WSL path) when running inside WSL; empty otherwise. SWE_WIN_HOME overrides.
win_home() {
  if [[ -n "${SWE_WIN_HOME:-}" ]]; then echo "$SWE_WIN_HOME"; return; fi
  grep -qi microsoft /proc/version 2>/dev/null || return 0
  local cmd p
  cmd="$(command -v cmd.exe 2>/dev/null || echo /mnt/c/Windows/System32/cmd.exe)"
  [[ -x "$cmd" ]] || return 0
  p="$(cd /mnt/c 2>/dev/null && "$cmd" /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r' | tail -1)"
  [[ -n "$p" && "$p" != *%* ]] && wslpath "$p" 2>/dev/null || true
}
WIN_HOME="$(win_home)"

kimi_bin() { command -v kimi 2>/dev/null || { [[ -x "$HOME/.kimi-code/bin/kimi" ]] && echo "$HOME/.kimi-code/bin/kimi"; } || true; }

agent_present() {
  case "$1" in
    claude)      command -v claude  >/dev/null 2>&1 || [[ -d "$HOME/.claude" ]] ;;
    copilot)     command -v copilot >/dev/null 2>&1 || [[ -d "$HOME/.copilot" ]] ;;
    antigravity) command -v agy     >/dev/null 2>&1 || [[ -d "$HOME/.gemini" ]] ;;
    kimi)        [[ -n "$(kimi_bin)" ]] || [[ -d "$HOME/.kimi-code" ]] || [[ -d "$HOME/.kimi" ]] ;;
    pi)          command -v pi      >/dev/null 2>&1 || [[ -d "$HOME/.pi" ]] ;;
    cursor)      command -v cursor  >/dev/null 2>&1 || command -v cursor-agent >/dev/null 2>&1 || [[ -d "$HOME/.cursor" ]] ;;
    # Cursor installed on Windows, seen from WSL: link in WSL too, for Cursor's WSL connection
    cursor-windows) [[ -n "$WIN_HOME" ]] && { [[ -d "$WIN_HOME/.cursor" ]] || [[ -d "$WIN_HOME/AppData/Local/Programs/cursor" ]]; } ;;
  esac
}

agent_selected() {
  [[ -z "$AGENTS_FILTER" ]] && return 0
  [[ ",$AGENTS_FILTER," == *",$1,"* ]]
}

# Global skill directories per agent (Kimi, pi and Cursor share ~/.agents/skills)
skill_dirs_for() {
  case "$1" in
    claude)      echo "$HOME/.claude/skills" ;;
    copilot)     echo "$HOME/.copilot/skills" ;;
    antigravity) echo "$HOME/.gemini/config/skills"; echo "$HOME/.gemini/antigravity/skills" ;;
    kimi|pi|cursor|cursor-windows) echo "$HOME/.agents/skills" ;;
  esac
}

ALL_AGENTS=(claude copilot antigravity kimi pi cursor cursor-windows)
ACTIVE_AGENTS=()
for a in "${ALL_AGENTS[@]}"; do
  if agent_selected "$a" && agent_present "$a"; then ACTIVE_AGENTS+=("$a"); fi
done

target_dirs() {
  local a d
  for a in "${ACTIVE_AGENTS[@]}"; do skill_dirs_for "$a"; done | awk '!seen[$0]++'
}

our_skills() { find "$SKILLS_SRC" -mindepth 2 -maxdepth 2 -name SKILL.md -printf '%h\n' | sort; }

# ---------- our skills ----------
link_skills() {
  local dir src name dest
  while IFS= read -r dir; do
    run mkdir -p "$dir"
    while IFS= read -r src; do
      name="$(basename "$src")"; dest="$dir/$name"
      if [[ -L "$dest" ]]; then
        if [[ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then continue; fi
        warn "$dest is a symlink to somewhere else; leaving it alone"; continue
      elif [[ -e "$dest" ]]; then
        warn "$dest exists and is not ours; leaving it alone"; continue
      fi
      run ln -s "$src" "$dest"
      ((DRY_RUN)) || printf '   linked %s -> %s\n' "$name" "$dir"
    done < <(our_skills)
  done < <(target_dirs)
}

unlink_skills() {
  local dir src dest
  for a in "${ALL_AGENTS[@]}"; do skill_dirs_for "$a"; done | awk '!seen[$0]++' | while IFS= read -r dir; do
    while IFS= read -r src; do
      dest="$dir/$(basename "$src")"
      if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
        run rm "$dest"; printf '   removed %s\n' "$dest"
      fi
    done < <(our_skills)
  done
}

# ---------- Windows-side agents (from WSL) ----------
# Windows apps can't follow WSL symlinks, so install.ps1 does the Windows side: it detects the
# Windows agents and copies the skills into their folders (marked as ours), plus toolbox packs.
WIN_PS=""
if [[ -n "$WIN_HOME" ]] && ((!NO_WINDOWS)); then
  WIN_PS="$(command -v powershell.exe 2>/dev/null || echo /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe)"
  [[ -x "$WIN_PS" ]] || WIN_PS=""
fi

windows_side() { # <install|update|status|uninstall>
  [[ -n "$WIN_PS" ]] || return 0
  info "Windows side: install.ps1 $1"
  local args=(-NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$REPO_DIR/install.ps1")" "$1" -FromWsl)
  ((DRY_RUN)) && args+=(-DryRun)
  ((SKIP_SP)) && args+=(-SkipSuperpowers)
  ((SKIP_ADDY)) && args+=(-SkipAddy)
  [[ -n "$AGENTS_FILTER" ]] && args+=(-Agents "$AGENTS_FILTER")
  [[ -n "${SWE_WIN_HOME:-}" ]] && args+=(-HomeDir "$(wslpath -w "$SWE_WIN_HOME")")
  # cmd/powershell warn when started from a WSL folder, so start them from C:
  (cd /mnt/c && "$WIN_PS" "${args[@]}" 2>&1 | tr -d '\r') || warn "Windows side failed; run install.ps1 from Windows instead"
  return 0
}

# ---------- toolbox: superpowers ----------
try() { # run a command, but never abort the whole install on failure
  if ((DRY_RUN)); then printf '%s\n' "${c_dim}[dry-run]${c_off} $*"; return 0; fi
  "$@" || { warn "command failed (may already be installed): $*"; return 0; }
}

install_superpowers() {
  info "Installing obra/superpowers (workflow toolbox)"
  local a
  for a in "${ACTIVE_AGENTS[@]}"; do
    case "$a" in
      claude)
        if command -v claude >/dev/null 2>&1; then
          if claude plugin list 2>/dev/null | grep -q 'superpowers'; then echo "   claude: already installed"
          else try claude plugin install superpowers@claude-plugins-official; fi
        fi ;;
      copilot)
        if command -v copilot >/dev/null 2>&1; then
          if copilot plugin list 2>/dev/null | grep -q 'superpowers'; then echo "   copilot: already installed"
          else
            try copilot plugin marketplace add obra/superpowers-marketplace
            try copilot plugin install superpowers@superpowers-marketplace
          fi
        fi ;;
      antigravity)
        if command -v agy >/dev/null 2>&1; then
          if agy plugin list 2>/dev/null | grep -q 'superpowers'; then echo "   antigravity: already installed"
          else try agy plugin install https://github.com/obra/superpowers; fi
        fi ;;
      pi)
        if command -v pi >/dev/null 2>&1; then
          if pi list 2>/dev/null | grep -q 'superpowers'; then echo "   pi: already installed"
          else try pi install git:github.com/obra/superpowers; fi
        fi ;;
      kimi)
        warn "kimi: plugin install is interactive. Inside Kimi Code run:  /plugins install https://github.com/obra/superpowers" ;;
      cursor)
        warn "cursor: plugin install is interactive. In Cursor Agent chat run:  /add-plugin superpowers" ;;
    esac
  done
}

# ---------- toolbox: addyosmani/agent-skills subset ----------
install_addy() {
  info "Installing addyosmani/agent-skills subset (security, CI/CD, observability, launch, ...)"
  if ! command -v npx >/dev/null 2>&1; then warn "npx not found; install Node.js to get these skills. Skipping."; return 0; fi
  local args=() a s
  for a in "${ACTIVE_AGENTS[@]}"; do
    case "$a" in
      claude) args+=(-a claude-code) ;;
      copilot) args+=(-a github-copilot) ;;
      antigravity) args+=(-a antigravity) ;;
      kimi) args+=(-a kimi-code-cli) ;;
      pi) args+=(-a pi) ;;
      cursor|cursor-windows) args+=(-a cursor) ;;
    esac
  done
  for s in "${ADDY_SKILLS[@]}"; do args+=(-s "$s"); done
  try npx -y skills add addyosmani/agent-skills -g -y "${args[@]}"
}

# ---------- project scaffolding ----------
init_project() {
  [[ -n "$INIT_DIR" ]] || { err "usage: ./install.sh init <project-dir>"; exit 1; }
  run mkdir -p "$INIT_DIR"
  local f rel dest
  while IFS= read -r f; do
    rel="${f#"$TEMPLATES"/}"; dest="$INIT_DIR/$rel"
    if [[ -e "$dest" ]]; then echo "   exists, kept: $rel"; continue; fi
    run mkdir -p "$(dirname "$dest")"
    run cp "$f" "$dest"
    echo "   created: $rel"
  done < <(find "$TEMPLATES" -type f | sort)
  if [[ ! -d "$INIT_DIR/.git" ]] && command -v git >/dev/null 2>&1; then run git -C "$INIT_DIR" init -q; echo "   git repo initialized"; fi
  info "Project ready (optional step: the orchestrator also does this itself). Open it in any agent and say:  /swe-orchestrator I want to build <your idea>"
}

status() {
  info "Detected agents: ${ACTIVE_AGENTS[*]:-none}"
  local dir n
  while IFS= read -r dir; do
    n=0
    while IFS= read -r src; do [[ -L "$dir/$(basename "$src")" ]] && n=$((n+1)); done < <(our_skills)
    printf '   %-45s %d/%d swe skills linked\n' "$dir" "$n" "$(our_skills | wc -l)"
  done < <(target_dirs)
}

case "$CMD" in
  install)
    ((${#ACTIVE_AGENTS[@]})) || [[ -n "$WIN_PS" ]] || { err "No supported agents detected."; exit 1; }
    info "Agents: ${ACTIVE_AGENTS[*]:-none}"
    info "Linking swe-* skills"
    link_skills
    ((SKIP_SP)) || install_superpowers
    ((SKIP_ADDY)) || install_addy
    status
    windows_side install
    info "Done. Make a folder, open any agent in it and say:  /swe-orchestrator I want to build <your idea>"
    ;;
  update)
    info "Pulling latest skills"
    if [[ -d "$REPO_DIR/.git" ]]; then run git -C "$REPO_DIR" pull --ff-only; else warn "not a git checkout; skipping pull"; fi
    info "Re-linking swe-* skills"; link_skills
    if ((!SKIP_SP)); then
      info "Updating superpowers"
      for a in "${ACTIVE_AGENTS[@]}"; do case "$a" in
        claude)  command -v claude  >/dev/null && try claude plugin update superpowers@claude-plugins-official ;;
        copilot) command -v copilot >/dev/null && try copilot plugin update superpowers@superpowers-marketplace ;;
        pi)      command -v pi      >/dev/null && try pi update git:github.com/obra/superpowers ;;
      esac; done
    fi
    ((SKIP_ADDY)) || install_addy
    status
    windows_side update ;;
  init) init_project ;;
  status) status; windows_side status ;;
  uninstall) info "Removing swe-* skill symlinks"; unlink_skills; windows_side uninstall
             warn "Toolbox packs (superpowers, addy) were left installed; remove them with each agent's plugin/skills command if wanted." ;;
esac
