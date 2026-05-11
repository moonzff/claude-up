#Requires -Version 5.1
<#
.SYNOPSIS
    Claude_up 部署脚本 — 将配置模板部署到 ~/.claude/

.DESCRIPTION
    支持按场景（Profile）选择性部署，默认为 dry-run 预览模式。

.PARAMETER Execute
    实际执行部署（默认为 dry-run，不修改任何文件）

.PARAMETER Profile
    部署场景：full（默认）| dev | assistant
    - full      : 部署所有文件（settings.json + CLAUDE.md）
    - dev       : 同 full，但在 CLAUDE.md 末尾追加 dev 场景提示
    - assistant : 同 full，但在 CLAUDE.md 末尾追加 assistant 场景提示

.PARAMETER ClaudeHome
    覆盖 Claude 配置目录路径（默认 $env:USERPROFILE\.claude）

.PARAMETER SourceDir
    覆盖源模板目录（默认脚本所在目录的父级 = 项目根目录）

.PARAMETER SkipBackup
    跳过已有文件的备份（默认备份为 .bak）

.EXAMPLE
    # 预览（不修改任何文件）
    .\install_claude_app.ps1

    # 完整部署
    .\install_claude_app.ps1 -Execute

    # 按开发场景部署
    .\install_claude_app.ps1 -Execute -Profile dev

    # 按助理场景部署
    .\install_claude_app.ps1 -Execute -Profile assistant

    # 跳过备份
    .\install_claude_app.ps1 -Execute -SkipBackup
#>

param(
    [switch]$Execute,
    [ValidateSet("full", "dev", "assistant")]
    [string]$Profile = "full",
    [string]$ClaudeHome = "",
    [string]$SourceDir = "",
    [switch]$SkipBackup
)

# ── 路径解析 ────────────────────────────────────────────────────────────────
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

if ([string]::IsNullOrEmpty($SourceDir))  { $SourceDir  = $ProjectRoot }
if ([string]::IsNullOrEmpty($ClaudeHome)) { $ClaudeHome = Join-Path $env:USERPROFILE ".claude" }

$TemplateDir = Join-Path $SourceDir "01-global-config\windows-claude"

# ── 输出工具 ────────────────────────────────────────────────────────────────
function Write-Step($msg)  { Write-Host "  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "  [COPY]     $msg" -ForegroundColor Green }
function Write-Dry($msg)   { Write-Host "  [DRY-RUN]  $msg" -ForegroundColor DarkYellow }
function Write-Bak($msg)   { Write-Host "  [BACKUP]   $msg" -ForegroundColor Yellow }
function Write-Err($msg)   { Write-Host "  [ERROR]    $msg" -ForegroundColor Red }
function Write-Create($msg){ Write-Host "  [CREATE]   $msg" -ForegroundColor Yellow }

# ── 头部 ────────────────────────────────────────────────────────────────────
$Mode = if ($Execute) { "EXECUTE" } else { "DRY-RUN" }
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Claude_up 部署脚本" -ForegroundColor Cyan
Write-Host "  模式: $Mode  |  Profile: $Profile" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  源目录   : $TemplateDir"
Write-Host "  目标目录 : $ClaudeHome"
Write-Host ""

# ── 前置检查 ────────────────────────────────────────────────────────────────
if (-not (Test-Path $TemplateDir)) {
    Write-Err "模板目录不存在: $TemplateDir"
    exit 1
}

$SettingsSrc = Join-Path $TemplateDir "settings.json"
$ClaudemdSrc = Join-Path $TemplateDir "CLAUDE.md"

foreach ($src in @($SettingsSrc, $ClaudemdSrc)) {
    if (-not (Test-Path $src)) {
        Write-Err "源文件不存在: $src"
        exit 1
    }
}

Write-Step "源文件确认 OK"
Write-Host "    · $SettingsSrc"
Write-Host "    · $ClaudemdSrc"
Write-Host ""

# ── 目标目录 ────────────────────────────────────────────────────────────────
$SettingsDst = Join-Path $ClaudeHome "settings.json"
$ClaudemdDst = Join-Path $ClaudeHome "CLAUDE.md"

if (-not (Test-Path $ClaudeHome)) {
    if ($Execute) {
        Write-Create "目录: $ClaudeHome"
        New-Item -ItemType Directory -Path $ClaudeHome -Force | Out-Null
    } else {
        Write-Dry "将创建目录: $ClaudeHome"
    }
} else {
    Write-Step "目标目录已存在: $ClaudeHome"
}
Write-Host ""

# ── 备份 ────────────────────────────────────────────────────────────────────
if (-not $SkipBackup) {
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    foreach ($dst in @($SettingsDst, $ClaudemdDst)) {
        if (Test-Path $dst) {
            $bak = "$dst.$ts.bak"
            if ($Execute) {
                Write-Bak "$dst → $(Split-Path -Leaf $bak)"
                Copy-Item -Path $dst -Destination $bak -Force
            } else {
                Write-Dry "将备份: $(Split-Path -Leaf $dst) → $(Split-Path -Leaf $bak)"
            }
        }
    }
    Write-Host ""
}

# ── 部署核心文件 ─────────────────────────────────────────────────────────────
$Files = @(
    @{ Src = $SettingsSrc; Dst = $SettingsDst; Label = "settings.json" },
    @{ Src = $ClaudemdSrc; Dst = $ClaudemdDst; Label = "CLAUDE.md" }
)

foreach ($f in $Files) {
    if ($Execute) {
        Write-Ok "$($f.Label)  →  $($f.Dst)"
        Copy-Item -Path $f.Src -Destination $f.Dst -Force
    } else {
        Write-Dry "$($f.Label)  →  $($f.Dst)"
    }
}
Write-Host ""

# ── Profile 附加配置 ─────────────────────────────────────────────────────────
if ($Profile -ne "full") {
    if ($Profile -eq "dev") {
        $profileNote = "`n`n<!-- Profile: dev (auto-appended by install_claude_app.ps1) -->`n## Active Profile: Development`n- 优先使用 dev Skills：grill-plan、diagnose、dual-environment-workflow`n- MCP: filesystem（读写）、playwright（E2E）、context7（文档查询）`n- Hooks: bash-audit（审计）、post-write-format（格式化）"
    } else {
        $profileNote = "`n`n<!-- Profile: assistant (auto-appended by install_claude_app.ps1) -->`n## Active Profile: Personal Assistant`n- 优先使用 assistant Skills：research-object-archive、summarize-meeting、weekly-review`n- MCP: filesystem（读写）`n- Hooks: research-trigger（归档提醒）、session-summary（会话日志）"
    }

    if ($Execute) {
        Write-Step "追加 Profile 配置到 CLAUDE.md ($Profile)"
        Add-Content -Path $ClaudemdDst -Value $profileNote
    } else {
        Write-Dry "将追加 Profile 配置到 CLAUDE.md ($Profile)"
        Write-Host ""
        Write-Host "  预览追加内容：" -ForegroundColor DarkGray
        $profileNote -split "`n" | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    }
    Write-Host ""
}

# ── 完成摘要 ────────────────────────────────────────────────────────────────
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

if ($Execute) {
    Write-Host "  ✓  部署完成  (Profile: $Profile)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  验证步骤："
    Write-Host "    1. 在 PowerShell 运行:"
    Write-Host "         .\cli\claude_app.ps1 doctor" -ForegroundColor DarkYellow
    Write-Host "    2. 在 PowerShell 运行:"
    Write-Host "         .\cli\claude_app.ps1 deploy-dry-run" -ForegroundColor DarkYellow
} else {
    Write-Host "  DRY-RUN 完成 — 未修改任何文件" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  确认无误后，加 -Execute 执行实际部署："
    $selfPath = $MyInvocation.MyCommand.Path
    Write-Host "    powershell -NoProfile -ExecutionPolicy Bypass -File '$selfPath' -Execute -Profile $Profile" -ForegroundColor DarkYellow
}

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
