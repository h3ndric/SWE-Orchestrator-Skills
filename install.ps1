# SWE Orchestrator Skills installer for Windows (Cursor and other agents that read ~/.agents/skills).
# WSL users: run ./install.sh inside WSL instead; it also covers Cursor installed on Windows.
#
# Usage (PowerShell, from the repo folder):
#   powershell -ExecutionPolicy Bypass -File install.ps1 [install|update|status|uninstall] [-DryRun] [-SkipAddy]
#
# Skills are linked with directory junctions (no admin rights needed), so `update` (git pull) is enough
# to refresh them. If junctions can't be made (e.g. the repo is on a network or WSL path), they are
# copied instead and marked so update/uninstall only touch our copies.
[CmdletBinding()]
param(
  [Parameter(Position = 0)][ValidateSet('install', 'update', 'status', 'uninstall')][string]$Command = 'install',
  [switch]$DryRun,
  [switch]$SkipAddy,
  [string]$SkillsDir = (Join-Path $env:USERPROFILE '.agents\skills')
)
$ErrorActionPreference = 'Stop'

$RepoDir = $PSScriptRoot
$SkillsSrc = Join-Path $RepoDir 'skills'
$Marker = '.installed-by-swe-orchestrator'
$AddySkills = @('security-and-hardening', 'ci-cd-and-automation', 'observability-and-instrumentation',
  'shipping-and-launch', 'documentation-and-adrs', 'api-and-interface-design',
  'performance-optimization', 'frontend-ui-engineering')

function Info($m) { Write-Host "==> $m" -ForegroundColor Green }
function Warn($m) { Write-Host "!! $m" -ForegroundColor Yellow }
function Act($desc, [scriptblock]$do) { if ($DryRun) { Write-Host "[dry-run] $desc" -ForegroundColor DarkGray } else { & $do } }

function Get-OurSkills { Get-ChildItem $SkillsSrc -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } | Sort-Object Name }

function Test-CursorPresent {
  (Get-Command cursor -ErrorAction SilentlyContinue) -or
  (Test-Path (Join-Path $env:LOCALAPPDATA 'Programs\cursor')) -or
  (Test-Path (Join-Path $env:USERPROFILE '.cursor'))
}

# 'junction' | 'copy' | 'foreign' | 'missing'
function Get-InstallState($dest, $src) {
  if (-not (Test-Path -LiteralPath $dest)) { return 'missing' }
  $item = Get-Item -LiteralPath $dest -Force
  if ($item.LinkType -eq 'Junction') {
    $target = @($item.Target)[0]
    if ($target -and ([IO.Path]::GetFullPath($target).TrimEnd('\') -ieq [IO.Path]::GetFullPath($src).TrimEnd('\'))) { return 'junction' }
    return 'foreign'
  }
  if (Test-Path -LiteralPath (Join-Path $dest $Marker)) { return 'copy' }
  return 'foreign'
}

function Install-Skill($src) {
  $name = Split-Path $src -Leaf
  $dest = Join-Path $SkillsDir $name
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
      if (-not $linked -and (Test-Path -LiteralPath $dest)) { (Get-Item -LiteralPath $dest -Force).Delete() }
    }
    if ($linked) { Write-Host "   linked $name" }
    else { Copy-Skill $src $dest; Write-Host "   copied $name (junction not possible here)" }
  }
}

function Copy-Skill($src, $dest) {
  Copy-Item -LiteralPath $src -Destination $dest -Recurse -Force
  Set-Content -LiteralPath (Join-Path $dest $Marker) -Value "Installed by $RepoDir. Re-run install.ps1 update to refresh."
}

function Install-All {
  Act "mkdir $SkillsDir" { New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null }
  foreach ($s in Get-OurSkills) { Install-Skill $s.FullName }
}

function Install-Addy {
  if ($SkipAddy) { return }
  if (-not (Get-Command npx -ErrorAction SilentlyContinue)) { Warn 'npx not found; install Node.js to get the toolbox skills. Skipping.'; return }
  Info 'Installing addyosmani/agent-skills subset (security, CI/CD, observability, launch, ...)'
  $npxArgs = @('-y', 'skills', 'add', 'addyosmani/agent-skills', '-g', '-y', '-a', 'cursor')
  foreach ($s in $AddySkills) { $npxArgs += @('-s', $s) }
  Act "npx $($npxArgs -join ' ')" { & npx @npxArgs; if ($LASTEXITCODE) { Warn 'addy install failed (may already be installed)' } }
}

function Show-Status {
  Info "Cursor detected: $([bool](Test-CursorPresent))"
  $all = @(Get-OurSkills); $n = 0
  foreach ($s in $all) { if ((Get-InstallState (Join-Path $SkillsDir $s.Name) $s.FullName) -in 'junction', 'copy') { $n++ } }
  Write-Host ("   {0,-45} {1}/{2} swe skills installed" -f $SkillsDir, $n, $all.Count)
}

function Remove-All {
  foreach ($s in Get-OurSkills) {
    $dest = Join-Path $SkillsDir $s.Name
    $state = Get-InstallState $dest $s.FullName
    if ($state -eq 'junction') { Act "remove junction $dest" { (Get-Item -LiteralPath $dest -Force).Delete(); Write-Host "   removed $dest" } }
    elseif ($state -eq 'copy') { Act "remove copy $dest" { Remove-Item -LiteralPath $dest -Recurse -Force; Write-Host "   removed $dest" } }
  }
}

switch ($Command) {
  'install' {
    if (-not (Test-CursorPresent)) { Warn 'Cursor not found; installing into the shared skills folder anyway.' }
    Info "Installing swe-* skills into $SkillsDir"; Install-All
    Install-Addy
    Warn 'Superpowers: in Cursor Agent chat run  /add-plugin superpowers'
    Show-Status
    Info 'Done. Open a project folder in Cursor and say:  /swe-orchestrator I want to build <your idea>'
  }
  'update' {
    if (Test-Path (Join-Path $RepoDir '.git')) { Info 'Pulling latest'; Act 'git pull --ff-only' { git -C $RepoDir pull --ff-only } }
    else { Warn 'not a git checkout; skipping pull' }
    Info 'Refreshing swe-* skills'; Install-All
    Install-Addy
    Show-Status
  }
  'status' { Show-Status }
  'uninstall' { Info 'Removing swe-* skills'; Remove-All; Warn 'Toolbox skills (addy) and the superpowers plugin were left installed.' }
}
