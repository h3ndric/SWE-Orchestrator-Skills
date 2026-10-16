# SWE Orchestrator Skills installer for Windows.
# Installs the swe-* skills into the Windows versions of Claude Code, GitHub Copilot CLI, Antigravity,
# Kimi Code, pi and Cursor, plus the toolbox packs (obra/superpowers, addyosmani/agent-skills subset).
# WSL users: run ./install.sh inside WSL instead; it calls this script for the Windows side.
#
# Usage (PowerShell, from the repo folder):
#   powershell -ExecutionPolicy Bypass -File install.ps1 [install|update|status|uninstall]
#       [-DryRun] [-SkipSuperpowers] [-SkipAddy] [-Agents claude,copilot,antigravity,kimi,pi,cursor]
#
# Skills are linked with directory junctions (no admin rights needed), so `update` (git pull) is enough
# to refresh them. If junctions can't work (e.g. the repo is on a network or WSL path), skills are
# copied instead and marked, so update/uninstall only ever touch our own copies.
[CmdletBinding()]
param(
  [Parameter(Position = 0)][ValidateSet('install', 'update', 'status', 'uninstall')][string]$Command = 'install',
  [switch]$DryRun,
  [switch]$SkipSuperpowers,
  [switch]$SkipAddy,
  [string[]]$Agents = @(),
  [switch]$FromWsl,                           # set by install.sh when it runs this from WSL
  [string]$HomeDir = $env:USERPROFILE         # override for testing
)
$ErrorActionPreference = 'Stop'

$RepoDir = $PSScriptRoot
$SkillsSrc = Join-Path $RepoDir 'skills'
$Marker = '.installed-by-swe-orchestrator'
$AddySkills = @('security-and-hardening', 'ci-cd-and-automation', 'observability-and-instrumentation',
  'shipping-and-launch', 'documentation-and-adrs', 'api-and-interface-design',
  'performance-optimization', 'frontend-ui-engineering')
# -Agents may arrive as one comma-separated string (e.g. from install.sh)
$Agents = @($Agents | ForEach-Object { $_ -split ',' } | Where-Object { $_ })

# Per agent: commands and home folders that mean "installed", skill folders (relative to home),
# and the agent id used by `npx skills add -a`.
$AgentTable = [ordered]@{
  claude      = @{ Cmds = @('claude');                Dirs = @('.claude');                                    Skills = @('.claude\skills');                                      Addy = 'claude-code' }
  copilot     = @{ Cmds = @('copilot');               Dirs = @('.copilot');                                   Skills = @('.copilot\skills');                                     Addy = 'github-copilot' }
  antigravity = @{ Cmds = @('agy');                   Dirs = @('.gemini');                                    Skills = @('.gemini\config\skills', '.gemini\antigravity\skills'); Addy = 'antigravity' }
  kimi        = @{ Cmds = @('kimi');                  Dirs = @('.kimi-code', '.kimi');                        Skills = @('.agents\skills');                                      Addy = 'kimi-code-cli' }
  pi          = @{ Cmds = @('pi');                    Dirs = @('.pi');                                        Skills = @('.agents\skills');                                      Addy = 'pi' }
  cursor      = @{ Cmds = @('cursor', 'cursor-agent'); Dirs = @('.cursor', 'AppData\Local\Programs\cursor'); Skills = @('.agents\skills');                                      Addy = 'cursor' }
}

function Info($m) { Write-Host "==> $m" -ForegroundColor Green }
function Warn($m) { Write-Host "!! $m" -ForegroundColor Yellow }
function Act($desc, [scriptblock]$do) { if ($DryRun) { Write-Host "[dry-run] $desc" -ForegroundColor DarkGray } else { & $do } }
function Has-Cmd($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# Run an external command without ever aborting the whole install.
function Try-Run([string]$exe, [string[]]$cmdArgs) {
  if ($DryRun) { Write-Host "[dry-run] $exe $($cmdArgs -join ' ')" -ForegroundColor DarkGray; return }
  $ErrorActionPreference = 'Continue'
  try { & $exe @cmdArgs; if ($LASTEXITCODE) { Warn "command failed (may already be installed): $exe $($cmdArgs -join ' ')" } }
  catch { Warn "command failed: $exe $($cmdArgs -join ' ') ($($_.Exception.Message))" }
}
function Lists-Superpowers([string]$exe, [string[]]$cmdArgs) {
  $ErrorActionPreference = 'Continue'
  try { return [bool]((& $exe @cmdArgs 2>$null | Out-String) -match 'superpowers') } catch { return $false }
}

function Test-AgentPresent($name) {
  $a = $AgentTable[$name]
  foreach ($c in $a.Cmds) { if (Has-Cmd $c) { return $true } }
  foreach ($d in $a.Dirs) { if (Test-Path (Join-Path $HomeDir $d)) { return $true } }
  return $false
}

$ActiveAgents = @($AgentTable.Keys | Where-Object { ($Agents.Count -eq 0 -or $Agents -contains $_) -and (Test-AgentPresent $_) })

function Get-TargetDirs { $ActiveAgents | ForEach-Object { $AgentTable[$_].Skills } | ForEach-Object { Join-Path $HomeDir $_ } | Select-Object -Unique }
function Get-AllDirs { $AgentTable.Keys | ForEach-Object { $AgentTable[$_].Skills } | ForEach-Object { Join-Path $HomeDir $_ } | Select-Object -Unique }
function Get-OurSkills { Get-ChildItem $SkillsSrc -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } | Sort-Object Name }

# ---------- our skills ----------
# 'junction' | 'copy' | 'foreign' | 'missing'
function Get-InstallState($dest, $src) {
  if (-not (Test-Path -LiteralPath $dest)) {
    # a dangling junction fails Test-Path but still occupies the name
    $item = Get-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
    if (-not $item) { return 'missing' }
  }
  $item = Get-Item -LiteralPath $dest -Force
  if ($item.LinkType -eq 'Junction') {
    $target = @($item.Target)[0]
    if ($target -and ([IO.Path]::GetFullPath($target).TrimEnd('\') -ieq [IO.Path]::GetFullPath($src).TrimEnd('\'))) { return 'junction' }
    return 'foreign'
  }
  if (Test-Path -LiteralPath (Join-Path $dest $Marker)) { return 'copy' }
  return 'foreign'
}

function Copy-Skill($src, $dest) {
  Copy-Item -LiteralPath $src -Destination $dest -Recurse -Force
  Set-Content -LiteralPath (Join-Path $dest $Marker) -Value "Installed by $RepoDir. Re-run the installer's update to refresh."
}

function Install-Skill($src, $dir) {
  $name = Split-Path $src -Leaf
  $dest = Join-Path $dir $name
  switch (Get-InstallState $dest $src) {
    'junction' { return }
    'foreign' { Warn "$dest exists and is not ours; leaving it alone"; return }
    'copy' { Act "refresh copy $dest" { Remove-Item -LiteralPath $dest -Recurse -Force; Copy-Skill $src $dest }; return }
  }
  Act "junction $dest -> $src" {
    # A junction to a network/WSL path is created without error but can't be read, so verify it.
    $linked = $false
    if (-not $src.StartsWith('\\')) {
      try { New-Item -ItemType Junction -Path $dest -Target $src | Out-Null; $linked = Test-Path -LiteralPath (Join-Path $dest 'SKILL.md') } catch { }
      if (-not $linked -and (Get-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue)) { (Get-Item -LiteralPath $dest -Force).Delete() }
    }
    if ($linked) { Write-Host "   linked $name -> $dir" }
    else { Copy-Skill $src $dest; Write-Host "   copied $name -> $dir" }
  }
}

function Install-All {
  foreach ($dir in Get-TargetDirs) {
    Act "mkdir $dir" { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    foreach ($s in Get-OurSkills) { Install-Skill $s.FullName $dir }
  }
}

function Remove-All {
  foreach ($dir in Get-AllDirs) {
    foreach ($s in Get-OurSkills) {
      $dest = Join-Path $dir $s.Name
      switch (Get-InstallState $dest $s.FullName) {
        'junction' { Act "remove junction $dest" { (Get-Item -LiteralPath $dest -Force).Delete(); Write-Host "   removed $dest" } }
        'copy' { Act "remove copy $dest" { Remove-Item -LiteralPath $dest -Recurse -Force; Write-Host "   removed $dest" } }
      }
    }
  }
}

# ---------- toolbox: superpowers ----------
function Install-Superpowers {
  if ($SkipSuperpowers) { return }
  Info 'Installing obra/superpowers (workflow toolbox)'
  foreach ($a in $ActiveAgents) {
    switch ($a) {
      'claude' {
        if (-not (Has-Cmd claude)) { continue }
        if (Lists-Superpowers claude @('plugin', 'list')) { Write-Host '   claude: already installed' }
        else { Try-Run claude @('plugin', 'install', 'superpowers@claude-plugins-official') }
      }
      'copilot' {
        if (-not (Has-Cmd copilot)) { continue }
        if (Lists-Superpowers copilot @('plugin', 'list')) { Write-Host '   copilot: already installed' }
        else {
          Try-Run copilot @('plugin', 'marketplace', 'add', 'obra/superpowers-marketplace')
          Try-Run copilot @('plugin', 'install', 'superpowers@superpowers-marketplace')
        }
      }
      'antigravity' {
        if (-not (Has-Cmd agy)) { continue }
        if (Lists-Superpowers agy @('plugin', 'list')) { Write-Host '   antigravity: already installed' }
        else { Try-Run agy @('plugin', 'install', 'https://github.com/obra/superpowers') }
      }
      'pi' {
        if (-not (Has-Cmd pi)) { continue }
        if (Lists-Superpowers pi @('list')) { Write-Host '   pi: already installed' }
        else { Try-Run pi @('install', 'git:github.com/obra/superpowers') }
      }
      'kimi' { Warn 'kimi: plugin install is interactive. Inside Kimi Code run:  /plugins install https://github.com/obra/superpowers' }
      'cursor' { Warn 'cursor: plugin install is interactive. In Cursor Agent chat run:  /add-plugin superpowers' }
    }
  }
}

function Update-Superpowers {
  if ($SkipSuperpowers) { return }
  Info 'Updating superpowers'
  foreach ($a in $ActiveAgents) {
    switch ($a) {
      'claude' { if (Has-Cmd claude) { Try-Run claude @('plugin', 'update', 'superpowers@claude-plugins-official') } }
      'copilot' { if (Has-Cmd copilot) { Try-Run copilot @('plugin', 'update', 'superpowers@superpowers-marketplace') } }
      'pi' { if (Has-Cmd pi) { Try-Run pi @('update', 'git:github.com/obra/superpowers') } }
    }
  }
}

# ---------- toolbox: addyosmani/agent-skills subset ----------
function Install-Addy {
  if ($SkipAddy -or $ActiveAgents.Count -eq 0) { return }
  Info 'Installing addyosmani/agent-skills subset (security, CI/CD, observability, launch, ...)'
  if (-not (Has-Cmd npx)) { Warn 'npx not found; install Node.js to get these skills. Skipping.'; return }
  $npxArgs = @('-y', 'skills', 'add', 'addyosmani/agent-skills', '-g', '-y')
  foreach ($a in $ActiveAgents) { $npxArgs += @('-a', $AgentTable[$a].Addy) }
  foreach ($s in $AddySkills) { $npxArgs += @('-s', $s) }
  Try-Run npx $npxArgs
}

function Show-Status {
  Info "Detected Windows agents: $(if ($ActiveAgents.Count) { $ActiveAgents -join ' ' } else { 'none' })"
  $all = @(Get-OurSkills)
  foreach ($dir in Get-TargetDirs) {
    $n = @($all | Where-Object { (Get-InstallState (Join-Path $dir $_.Name) $_.FullName) -in 'junction', 'copy' }).Count
    Write-Host ("   {0,-45} {1}/{2} swe skills installed" -f $dir, $n, $all.Count)
  }
}

switch ($Command) {
  'install' {
    if ($ActiveAgents.Count -eq 0) { Warn 'No supported agents found on Windows. Install one, then re-run.'; return }
    Info "Agents: $($ActiveAgents -join ' ')"
    Info 'Installing swe-* skills'; Install-All
    Install-Superpowers
    Install-Addy
    Show-Status
    if (-not $FromWsl) { Info 'Done. Make a folder, open any agent in it and say:  /swe-orchestrator I want to build <your idea>' }
  }
  'update' {
    if (-not $FromWsl) {
      if ((Test-Path (Join-Path $RepoDir '.git')) -and (Has-Cmd git)) { Info 'Pulling latest skills'; Try-Run git @('-C', $RepoDir, 'pull', '--ff-only') }
      else { Warn 'not a git checkout (or git not installed); skipping pull' }
    }
    Info 'Refreshing swe-* skills'; Install-All
    Update-Superpowers
    Install-Addy
    Show-Status
  }
  'status' { Show-Status }
  'uninstall' {
    Info 'Removing swe-* skills'; Remove-All
    Warn 'Toolbox packs (superpowers, addy) were left installed; remove them with each agent''s plugin/skills command if wanted.'
  }
}
