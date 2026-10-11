<#
.SYNOPSIS
Link vstack packs' skills (and agents, where the harness supports them) into one or more agent harnesses on Windows.

.DESCRIPTION
Skill directories are linked with directory junctions, which need no admin rights or Developer Mode.
Agent files are linked with a symbolic link when Windows allows it, otherwise a hard link.
Edits in this repo take effect immediately. Existing skills are never overwritten.

.EXAMPLE
.\install.ps1 claude cursor
.\install.ps1 -Pack core codex
.\install.ps1 -Project ~\work\my-app agents
.\install.ps1 -Uninstall all
#>
[CmdletBinding()]
param(
  [string[]]$Pack = @(),
  [string]$Project,
  [switch]$Uninstall,
  [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
  [ValidateSet('claude', 'cursor', 'codex', 'gemini', 'agents', 'all')]
  [string[]]$Harness
)

$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot
$base = if ($Project) { (Resolve-Path $Project).Path } else { $HOME }

if (-not $Harness) {
  Write-Error 'Name at least one harness: claude, cursor, codex, gemini, agents, or all. See Get-Help .\install.ps1'
}
$harnesses = @($Harness | ForEach-Object { if ($_ -eq 'all') { 'claude', 'cursor', 'codex', 'gemini', 'agents' } else { $_ } }) | Select-Object -Unique

foreach ($p in $Pack) {
  if (-not (Test-Path (Join-Path $src "packs\$p") -PathType Container)) { Write-Error "unknown pack: $p" }
}
$packs = if ($Pack.Count -eq 0) {
  Get-ChildItem (Join-Path $src 'packs') -Directory | ForEach-Object Name
} elseif (-not $Uninstall -and $Pack -notcontains 'core') {
  @('core') + $Pack
} else {
  $Pack
}

function Get-LinkTargets($item) {
  @($item.Target) | Where-Object { $_ } | ForEach-Object { $_ -replace '^\\\\\?\\', '' }
}

function Test-PointsAt($item, [string]$from) {
  if ($item.LinkType -eq 'HardLink') {
    return (fsutil file queryfileid $item.FullName) -eq (fsutil file queryfileid $from)
  }
  return (Get-LinkTargets $item) -contains $from
}

function Set-Link([string]$from, [string]$to, [switch]$File) {
  $item = Get-Item $to -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType) {
    if (Test-PointsAt $item $from) {
      if ($Uninstall) {
        if ($item.LinkType -eq 'HardLink') { Remove-Item $to -Force } else { $item.Delete() }
        Write-Host "  removed $to"
      }
      return
    }
    Write-Warning "skip $to ($($item.LinkType) not pointing at vstack)"
    return
  }
  if ($Uninstall) { return }
  if ($item) { Write-Warning "skip $to (already exists)"; return }

  New-Item -ItemType Directory -Force (Split-Path $to) | Out-Null
  if (-not $File) {
    New-Item -ItemType Junction -Path $to -Target $from | Out-Null
  } else {
    try { New-Item -ItemType SymbolicLink -Path $to -Target $from | Out-Null }
    catch { New-Item -ItemType HardLink -Path $to -Target $from | Out-Null }
  }
  Write-Host "  linked $to"
}

foreach ($h in $harnesses) {
  $dir = Join-Path $base ".$h"
  Write-Host "$h -> $dir"
  foreach ($p in $packs) {
    foreach ($skill in Get-ChildItem (Join-Path $src "packs\$p\skills") -Directory) {
      Set-Link $skill.FullName (Join-Path $dir "skills\$($skill.Name)")
    }
    if ($h -in 'claude', 'cursor') {
      $agents = Join-Path $src "packs\$p\agents"
      if (Test-Path $agents) {
        foreach ($agent in Get-ChildItem $agents -Filter *.md -File) {
          Set-Link $agent.FullName (Join-Path $dir "agents\$($agent.Name)") -File
        }
      }
    }
  }
}
