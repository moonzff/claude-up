#Requires -Version 5.1
param(
    [switch]$Execute,
    [ValidateSet("full", "dev", "assistant")]
    [string]$Profile = "full",
    [string]$ClaudeHome = "",
    [string]$SourceDir = "",
    [switch]$SkipBackup
)

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

if ([string]::IsNullOrEmpty($SourceDir))  { $SourceDir  = $ProjectRoot }
if ([string]::IsNullOrEmpty($ClaudeHome)) { $ClaudeHome = Join-Path $env:USERPROFILE ".claude" }

$TemplateDir = Join-Path $SourceDir "01-global-config\windows-claude"

function Write-Step($msg)  { Write-Host "  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "  [COPY]    $msg" -ForegroundColor Green }
function Write-Dry($msg)   { Write-Host "  [DRY-RUN] $msg" -ForegroundColor DarkYellow }
function Write-Bak($msg)   { Write-Host "  [BACKUP]  $msg" -ForegroundColor Yellow }
function Write-Err($msg)   { Write-Host "  [ERROR]   $msg" -ForegroundColor Red }

$Mode = if ($Execute) { "EXECUTE" } else { "DRY-RUN" }
Write-Host ""
Write-Host "-------------------------------------------------------" -ForegroundColor Cyan
Write-Host "  Claude_up deploy | Mode: $Mode | Profile: $Profile" -ForegroundColor Cyan
Write-Host "  Source : $TemplateDir" -ForegroundColor Cyan
Write-Host "  Target : $ClaudeHome" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $TemplateDir)) {
    Write-Err "Template dir not found: $TemplateDir"
    exit 1
}

$SettingsSrc = Join-Path $TemplateDir "settings.json"
$ClaudemdSrc = Join-Path $TemplateDir "CLAUDE.md"

foreach ($src in @($SettingsSrc, $ClaudemdSrc)) {
    if (-not (Test-Path $src)) {
        Write-Err "Source not found: $src"
        exit 1
    }
}

Write-Step "Source files OK:"
Write-Host "    $SettingsSrc"
Write-Host "    $ClaudemdSrc"
Write-Host ""

$SettingsDst = Join-Path $ClaudeHome "settings.json"
$ClaudemdDst = Join-Path $ClaudeHome "CLAUDE.md"

if (-not (Test-Path $ClaudeHome)) {
    if ($Execute) {
        Write-Host "  [CREATE]  $ClaudeHome" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $ClaudeHome -Force | Out-Null
    } else {
        Write-Dry "Will create dir: $ClaudeHome"
    }
} else {
    Write-Step "Target dir exists: $ClaudeHome"
}
Write-Host ""

if (-not $SkipBackup) {
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    foreach ($dst in @($SettingsDst, $ClaudemdDst)) {
        if (Test-Path $dst) {
            $bak = "$dst.$ts.bak"
            if ($Execute) {
                Write-Bak "$(Split-Path -Leaf $dst) -> $(Split-Path -Leaf $bak)"
                Copy-Item -Path $dst -Destination $bak -Force
            } else {
                Write-Dry "Will backup: $(Split-Path -Leaf $dst) -> $(Split-Path -Leaf $bak)"
            }
        }
    }
    Write-Host ""
}

$Files = @(
    @{ Src = $SettingsSrc; Dst = $SettingsDst; Label = "settings.json" },
    @{ Src = $ClaudemdSrc; Dst = $ClaudemdDst; Label = "CLAUDE.md" }
)

foreach ($f in $Files) {
    if ($Execute) {
        Write-Ok "$($f.Label)  ->  $($f.Dst)"
        Copy-Item -Path $f.Src -Destination $f.Dst -Force
    } else {
        Write-Dry "$($f.Label)  ->  $($f.Dst)"
    }
}
Write-Host ""

Write-Host "-------------------------------------------------------" -ForegroundColor Cyan
if ($Execute) {
    Write-Host "  [DONE] Deploy complete (Profile: $Profile)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next: restart Claude Code, then run:"
    Write-Host "    claude mcp list" -ForegroundColor DarkYellow
} else {
    Write-Host "  DRY-RUN complete — no files changed." -ForegroundColor Yellow
    Write-Host ""
    $selfPath = $MyInvocation.MyCommand.Path
    Write-Host "  To apply, run:"
    Write-Host "    powershell -NoProfile -ExecutionPolicy Bypass -File '$selfPath' -Execute" -ForegroundColor DarkYellow
}
Write-Host "-------------------------------------------------------" -ForegroundColor Cyan
Write-Host ""
