# Scheduled harness review for Windows (without WSL). Same job as scripts/harness-review.sh:
# runs the swe-harness-review skill unattended so lessons logged in projects' docs/HARNESS-FEEDBACK.md
# become skill fixes sent to the owner for approval. Covers local projects and GitHub projects.
#
# Usage (PowerShell, from the repo folder):
#   powershell -ExecutionPolicy Bypass -File scripts\harness-review.ps1 [run [-Now]|schedule|unschedule|status]
#
# Settings (environment): SWE_REVIEW_AGENT=claude|pi|copilot (default: first one installed),
#   SWE_REVIEW_CMD='my-agent -p $env:PROMPT' (custom agent command, run with the prompt in $env:PROMPT),
#   SWE_REVIEW_EVERY_DAYS=7, SWE_PROJECT_ROOTS="C:\Users\me\dev;D:\work", SWE_STATE_DIR (default ~\.swe-orchestrator)
[CmdletBinding()]
param(
  [Parameter(Position = 0)][ValidateSet('run', 'schedule', 'unschedule', 'status')][string]$Command = 'status',
  [switch]$Now
)
$ErrorActionPreference = 'Stop'

$RepoDir = Split-Path $PSScriptRoot -Parent
$StateDir = if ($env:SWE_STATE_DIR) { $env:SWE_STATE_DIR } else { Join-Path $env:USERPROFILE '.swe-orchestrator' }
$LogDir = Join-Path $StateDir 'logs'
$EveryDays = if ($env:SWE_REVIEW_EVERY_DAYS) { [int]$env:SWE_REVIEW_EVERY_DAYS } else { 7 }
$TaskName = 'SWE Harness Review'
$Prompt = "Use the swe-harness-review skill. This is a scheduled, unattended run: do not ask questions or wait for input. Collect new harness feedback from all projects (local and GitHub) and, if there are new lessons, prepare the improvements and deliver them for the owner's approval as the skill describes."
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Log($m) { $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $m"; Write-Host $line; Add-Content -Path (Join-Path $LogDir 'harness-review.log') -Value $line }
function Has-Cmd($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

function Get-ProjectRoots {
  $roots = if ($env:SWE_PROJECT_ROOTS) { $env:SWE_PROJECT_ROOTS -split ';' } else { @(Join-Path $env:USERPROFILE 'dev') }
  $reg = Join-Path $StateDir 'projects.tsv'
  if (Test-Path $reg) { $roots += Get-Content $reg | ForEach-Object { ($_ -split "`t")[0] } }
  $roots | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique
}

function Get-FeedbackFiles {
  $repo = [IO.Path]::GetFullPath($RepoDir)
  foreach ($r in Get-ProjectRoots) {
    Get-ChildItem -Path $r -Filter 'HARNESS-FEEDBACK.md' -Recurse -Depth 5 -File -ErrorAction SilentlyContinue |
      Where-Object { $_.Directory.Name -eq 'docs' -and $_.FullName -notmatch '\\(node_modules|\.git)\\' -and -not $_.FullName.StartsWith($repo) }
  }
}

function Test-Gh {
  if (-not (Has-Cmd gh)) { return $false }
  $ErrorActionPreference = 'Continue'; & gh auth status *> $null; return ($LASTEXITCODE -eq 0)
}

# A fingerprint of all feedback, local and on GitHub, so an agent only starts when something changed.
function Get-Fingerprint {
  $parts = @(Get-FeedbackFiles | Sort-Object FullName -Unique | ForEach-Object { (Get-FileHash $_.FullName -Algorithm SHA256).Hash + ' ' + $_.FullName })
  if (Test-Gh) {
    $ErrorActionPreference = 'Continue'
    $me = & gh api user --jq .login 2>$null
    if ($me) { $parts += @(& gh search code --owner $me --filename HARNESS-FEEDBACK.md --json repository,sha --jq '.[] | "\(.sha) gh:\(.repository.nameWithOwner)"' 2>$null) }
  }
  $text = ($parts | Sort-Object) -join "`n"
  $bytes = [Text.Encoding]::UTF8.GetBytes($text)
  -join ([Security.Cryptography.SHA256]::Create().ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') })
}

function Get-Agent {
  if ($env:SWE_REVIEW_CMD) { return 'custom' }
  if ($env:SWE_REVIEW_AGENT) { return $env:SWE_REVIEW_AGENT }
  foreach ($a in 'claude', 'pi', 'copilot') { if (Has-Cmd $a) { return $a } }
  'none'
}

function Invoke-Agent($agent, $out) {
  $ErrorActionPreference = 'Continue'
  Push-Location $RepoDir
  try {
    switch ($agent) {
      'claude' {
        $a = @('-p', $Prompt, '--permission-mode', 'acceptEdits', '--add-dir', $StateDir)
        foreach ($r in Get-ProjectRoots) { $a += @('--add-dir', $r) }
        $a += @('--allowedTools', 'Read', 'Edit', 'Write', 'Glob', 'Grep', 'Bash(git:*)', 'Bash(gh:*)', 'PowerShell(git:*)', 'PowerShell(gh:*)')
        & claude @a *>> $out
      }
      'pi' { & pi -p $Prompt *>> $out }
      'copilot' { & copilot -p $Prompt --allow-all-tools *>> $out }
      'custom' { $env:PROMPT = $Prompt; Invoke-Expression $env:SWE_REVIEW_CMD *>> $out }
      default { Log 'no supported agent found (claude, pi, copilot); set SWE_REVIEW_AGENT'; return $false }
    }
    return ($LASTEXITCODE -eq 0)
  } finally { Pop-Location }
}

function Invoke-Run {
  $lastFile = Join-Path $StateDir 'last-review-run'; $fpFile = Join-Path $StateDir 'last-review-fingerprint'
  $nowS = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  $last = if (Test-Path $lastFile) { [long](Get-Content $lastFile -Raw) } else { 0 }
  if (-not $Now -and ($nowS - $last) -lt ($EveryDays * 86400)) { return }   # not due; stay quiet

  $fp = Get-Fingerprint
  $lastFp = if (Test-Path $fpFile) { (Get-Content $fpFile -Raw).Trim() } else { '' }
  if (-not $Now -and $fp -eq $lastFp) { Log 'no new harness feedback; nothing to review'; Set-Content $lastFile $nowS; return }
  if (Has-Cmd git) {
    $dirty = & git -C $RepoDir status --porcelain
    if ($dirty) { Log 'skipped: the harness repo has uncommitted changes; will retry tomorrow'; return }
  }
  $agent = Get-Agent
  $out = Join-Path $LogDir "review-$(Get-Date -Format 'yyyy-MM-dd').log"
  Log "starting harness review with $agent (output: $out)"
  if (Invoke-Agent $agent $out) { Set-Content $lastFile $nowS; Set-Content $fpFile $fp; Log 'harness review finished' }
  else { Log "harness review failed (see $out); will retry tomorrow"; exit 1 }
}

switch ($Command) {
  'run' { Invoke-Run }
  'schedule' {
    $script = Join-Path $PSScriptRoot 'harness-review.ps1'
    $a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`" run"
    $t = New-ScheduledTaskTrigger -Daily -At 10:00
    $s = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 3)
    Register-ScheduledTask -TaskName $TaskName -Description "Weekly review of harness feedback (SWE Orchestrator). Checks daily, runs at most every $EveryDays days." -Action $a -Trigger $t -Settings $s -Force | Out-Null
    Write-Host "scheduled in Windows Task Scheduler: $TaskName (daily check at 10:00, catches up if the PC was off)"
  }
  'unschedule' {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) { Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false; Write-Host 'removed from Windows Task Scheduler' }
    else { Write-Host 'not scheduled' }
  }
  'status' {
    $lastFile = Join-Path $StateDir 'last-review-run'
    $last = if (Test-Path $lastFile) { [DateTimeOffset]::FromUnixTimeSeconds([long](Get-Content $lastFile -Raw)).LocalDateTime.ToString('yyyy-MM-dd HH:mm') } else { 'never' }
    $sched = if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) { 'Windows Task Scheduler' } else { 'not scheduled' }
    $waiting = @(Get-ChildItem (Join-Path $StateDir 'reports') -Filter *.md -ErrorAction SilentlyContinue | Where-Object { (Get-Content $_.FullName -TotalCount 1) -match '^Status: waiting for owner' }).Count
    Write-Host "Schedule:        $sched"
    Write-Host "Last review:     $last"
    Write-Host "Review agent:    $(Get-Agent)"
    Write-Host "GitHub:          $(if (Test-Gh) { 'connected (GitHub projects included)' } else { 'not connected (local projects only)' })"
    Write-Host "Feedback files:  $(@(Get-FeedbackFiles).Count) local"
    Write-Host "Waiting reviews: $waiting (reports in $(Join-Path $StateDir 'reports'))"
  }
}
