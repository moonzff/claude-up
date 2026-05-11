#Requires -Version 5.1
<#
.SYNOPSIS
    Claude_up Diagnostic CLI — 检查 Claude Code 本地环境健康状态

.DESCRIPTION
    命令列表：
      doctor          全量健康检查（推荐首次运行）
      mcp-check       列出 settings.json 中已配置的 MCP 服务器
      skill-list      枚举 Claude_up/02-skills/ 下所有已安装 Skills
      config-validate 验证 settings.json 结构完整性
      memory-audit    检查 CLAUDE.md 行数及 @import 链
      deploy-dry-run  对比模板文件与已部署文件的差异

.EXAMPLE
    .\claude_app.ps1 doctor
    .\claude_app.ps1 mcp-check
    .\claude_app.ps1 skill-list
    .\claude_app.ps1 config-validate
    .\claude_app.ps1 memory-audit
    .\claude_app.ps1 deploy-dry-run
#>

param(
    [Parameter(Position = 0)]
    [ValidateSet("doctor", "mcp-check", "skill-list", "config-validate", "memory-audit", "deploy-dry-run", "help")]
    [string]$Command = "help"
)

# ── 路径常量 ────────────────────────────────────────────────────────────────
$ClaudeHome    = "$Env:USERPROFILE\.claude"
$DeployedJson  = "$ClaudeHome\settings.json"
$DeployedMd    = "$ClaudeHome\CLAUDE.md"
$ScriptRoot    = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot      = Split-Path -Parent $ScriptRoot
$TemplateJson  = "$RepoRoot\01-global-config\windows-claude\settings.json"
$TemplateMd    = "$RepoRoot\01-global-config\windows-claude\CLAUDE.md"
$SkillsDir     = "$RepoRoot\02-skills"
$HooksDir      = "$RepoRoot\04-hooks"
$McpDir        = "$RepoRoot\05-mcp"

# ── 输出工具 ────────────────────────────────────────────────────────────────
function Write-Header($text) {
    Write-Host ""
    Write-Host "══════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════════" -ForegroundColor DarkCyan
}
function Write-Ok($msg)   { Write-Host "  ✓  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  ⚠  $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "  ✗  $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "  ·  $msg" -ForegroundColor Gray }

# ── 辅助：读取并解析 JSON ────────────────────────────────────────────────────
function Read-Json($path) {
    if (-not (Test-Path $path)) { return $null }
    try { Get-Content $path -Raw | ConvertFrom-Json }
    catch { return $null }
}

# ════════════════════════════════════════════════════════════════════════════
# COMMAND: config-validate
# ════════════════════════════════════════════════════════════════════════════
function Invoke-ConfigValidate($jsonPath, [switch]$Silent) {
    $pass = $true

    if (-not (Test-Path $jsonPath)) {
        if (-not $Silent) { Write-Fail "文件不存在: $jsonPath" }
        return $false
    }

    $raw = Get-Content $jsonPath -Raw
    try { $cfg = $raw | ConvertFrom-Json }
    catch {
        if (-not $Silent) { Write-Fail "JSON 解析失败: $_" }
        return $false
    }

    # 必需顶层字段
    $required = @("permissions", "env", "hooks", "mcpServers")
    foreach ($field in $required) {
        if ($null -eq $cfg.$field) {
            if (-not $Silent) { Write-Warn "缺少字段: $field" }
            $pass = $false
        } else {
            if (-not $Silent) { Write-Ok "字段存在: $field" }
        }
    }

    # permissions.allow / deny
    if ($cfg.permissions) {
        $allowCount = if ($cfg.permissions.allow) { $cfg.permissions.allow.Count } else { 0 }
        $denyCount  = if ($cfg.permissions.deny)  { $cfg.permissions.deny.Count  } else { 0 }
        if (-not $Silent) { Write-Info "permissions.allow: $allowCount 条  |  permissions.deny: $denyCount 条" }
    }

    # hooks 事件检查
    if ($cfg.hooks) {
        $hookEvents = @("PreToolUse", "PostToolUse", "Stop")
        foreach ($ev in $hookEvents) {
            if ($cfg.hooks.$ev) {
                $count = $cfg.hooks.$ev.Count
                if (-not $Silent) { Write-Ok "hooks.${ev}: $count 个规则" }
            } else {
                if (-not $Silent) { Write-Warn "hooks.${ev}: 未配置" }
            }
        }
    }

    # mcpServers
    if ($cfg.mcpServers) {
        $servers = $cfg.mcpServers.PSObject.Properties.Name
        if (-not $Silent) { Write-Info "mcpServers: $($servers -join ', ')" }
    }

    return $pass
}

# ════════════════════════════════════════════════════════════════════════════
# COMMAND: mcp-check
# ════════════════════════════════════════════════════════════════════════════
function Invoke-McpCheck {
    Write-Header "MCP Server Check"

    $cfg = Read-Json $DeployedJson
    if (-not $cfg) {
        Write-Fail "无法读取已部署的 settings.json: $DeployedJson"
        Write-Info "请先运行 deploy_execute.bat 部署配置文件"
        return
    }

    if (-not $cfg.mcpServers) {
        Write-Warn "settings.json 中未找到 mcpServers 字段"
        return
    }

    $servers = $cfg.mcpServers.PSObject.Properties
    Write-Info "已配置 MCP 服务器: $($servers.Name -join ', ')"
    Write-Host ""

    foreach ($srv in $servers) {
        $name = $srv.Name
        $conf = $srv.Value
        $cmd  = $conf.command
        $args = if ($conf.args) { $conf.args -join " " } else { "" }

        # 检查 command 是否可用
        $cmdAvail = $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
        if ($cmdAvail) {
            Write-Ok "$name  →  $cmd $args"
        } else {
            Write-Warn "$name  →  $cmd 未找到（需安装 Node.js / npx）"
        }
    }

    Write-Host ""
    Write-Info "提示：MCP 服务器实际连接状态需在 Claude Code 会话中通过 /mcp 验证"
}

# ════════════════════════════════════════════════════════════════════════════
# COMMAND: skill-list
# ════════════════════════════════════════════════════════════════════════════
function Invoke-SkillList {
    Write-Header "Skill List"

    if (-not (Test-Path $SkillsDir)) {
        Write-Fail "Skills 目录不存在: $SkillsDir"
        return
    }

    $skills = Get-ChildItem -Path $SkillsDir -Filter "SKILL.md" -Recurse | Sort-Object FullName
    if ($skills.Count -eq 0) {
        Write-Warn "未找到任何 SKILL.md 文件"
        return
    }

    Write-Info "共找到 $($skills.Count) 个 Skills:`n"

    foreach ($skill in $skills) {
        # 从 SKILL.md YAML frontmatter 提取 name 和 description
        $content = Get-Content $skill.FullName -TotalCount 15 -ErrorAction SilentlyContinue
        $name    = ($content | Select-String "^name:").Line -replace "^name:\s*", "" -replace '"', ''
        $desc    = ($content | Select-String "^description:").Line -replace "^description:\s*", "" -replace '"', ''

        # 相对路径
        $rel = $skill.FullName.Replace($RepoRoot + "\", "")
        $scenario = if ($rel -like "*\dev\*") { "Dev" } elseif ($rel -like "*\assistant\*") { "Assistant" } else { "Unknown" }

        $displayName = if ($name) { $name } else { $skill.Directory.Name }
        $displayDesc = if ($desc) { $desc } else { "(无描述)" }
        if ($displayDesc.Length -gt 60) { $displayDesc = $displayDesc.Substring(0, 57) + "..." }

        Write-Host "  " -NoNewline
        Write-Host "[$scenario]" -ForegroundColor DarkYellow -NoNewline
        Write-Host " $displayName" -ForegroundColor White -NoNewline
        Write-Host "  —  $displayDesc" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Info "Skills 目录: $SkillsDir"
}

# ════════════════════════════════════════════════════════════════════════════
# COMMAND: memory-audit
# ════════════════════════════════════════════════════════════════════════════
function Invoke-MemoryAudit {
    Write-Header "Memory Audit (CLAUDE.md)"

    # 检查已部署版本
    Write-Host ""
    Write-Host "  [已部署] $DeployedMd" -ForegroundColor DarkCyan
    if (Test-Path $DeployedMd) {
        $lines   = (Get-Content $DeployedMd).Count
        $imports = (Get-Content $DeployedMd | Select-String "@import").Matches.Count

        if ($lines -le 200) {
            Write-Ok "行数: $lines / 200  (在限制内)"
        } else {
            Write-Fail "行数: $lines / 200  ⚠ 超过推荐上限！"
        }

        if ($imports -gt 0) {
            Write-Info "@import 指令: $imports 个"
            Get-Content $DeployedMd | Select-String "@import" | ForEach-Object {
                Write-Info "    $_"
            }
        } else {
            Write-Info "@import 指令: 无"
        }
    } else {
        Write-Fail "未找到已部署的 CLAUDE.md"
        Write-Info "请先运行 deploy_execute.bat"
    }

    # 检查模板版本
    Write-Host ""
    Write-Host "  [模板] $TemplateMd" -ForegroundColor DarkCyan
    if (Test-Path $TemplateMd) {
        $lines = (Get-Content $TemplateMd).Count
        if ($lines -le 200) {
            Write-Ok "行数: $lines / 200"
        } else {
            Write-Warn "行数: $lines / 200  (建议精简)"
        }
    } else {
        Write-Warn "未找到模板 CLAUDE.md"
    }
}

# ════════════════════════════════════════════════════════════════════════════
# COMMAND: deploy-dry-run
# ════════════════════════════════════════════════════════════════════════════
function Invoke-DeployDryRun {
    Write-Header "Deploy Dry-Run  (模板 vs 已部署)"

    $files = @(
        @{ Name = "settings.json"; Template = $TemplateJson; Deployed = $DeployedJson },
        @{ Name = "CLAUDE.md";    Template = $TemplateMd;   Deployed = $DeployedMd  }
    )

    foreach ($f in $files) {
        Write-Host ""
        Write-Host "  ── $($f.Name) ──" -ForegroundColor DarkCyan

        $tExists = Test-Path $f.Template
        $dExists = Test-Path $f.Deployed

        if (-not $tExists) { Write-Fail "模板不存在: $($f.Template)"; continue }
        if (-not $dExists) {
            Write-Warn "尚未部署，运行 deploy_execute.bat 后会新建此文件"
            continue
        }

        $tHash = (Get-FileHash $f.Template -Algorithm MD5).Hash
        $dHash = (Get-FileHash $f.Deployed -Algorithm MD5).Hash

        if ($tHash -eq $dHash) {
            Write-Ok "已同步  (MD5: $tHash)"
        } else {
            Write-Warn "存在差异！需要重新部署"
            $tTime = (Get-Item $f.Template).LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            $dTime = (Get-Item $f.Deployed).LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            Write-Info "模板修改时间:   $tTime"
            Write-Info "已部署修改时间: $dTime"

            # 显示行数差异
            $tLines = (Get-Content $f.Template).Count
            $dLines = (Get-Content $f.Deployed).Count
            Write-Info "模板行数: $tLines  |  已部署行数: $dLines"
        }
    }

    Write-Host ""
    Write-Info "如有差异，运行: $RepoRoot\06-deployment-kit\deploy_execute.bat"
}

# ════════════════════════════════════════════════════════════════════════════
# COMMAND: doctor  (综合所有检查)
# ════════════════════════════════════════════════════════════════════════════
function Invoke-Doctor {
    Write-Header "Claude_up Doctor  —  全量健康检查"
    $issues = 0

    # 1. ~/.claude 目录
    Write-Host ""
    Write-Host "  [1/6] Claude Home 目录" -ForegroundColor DarkCyan
    if (Test-Path $ClaudeHome) {
        Write-Ok "$ClaudeHome 存在"
    } else {
        Write-Fail "$ClaudeHome 不存在"
        $issues++
    }

    # 2. settings.json 存在
    Write-Host ""
    Write-Host "  [2/6] settings.json 部署状态" -ForegroundColor DarkCyan
    if (Test-Path $DeployedJson) {
        Write-Ok "已部署: $DeployedJson"
        # 同步状态
        if (Test-Path $TemplateJson) {
            $tHash = (Get-FileHash $TemplateJson -Algorithm MD5).Hash
            $dHash = (Get-FileHash $DeployedJson -Algorithm MD5).Hash
            if ($tHash -eq $dHash) {
                Write-Ok "与模板同步"
            } else {
                Write-Warn "与模板存在差异 — 建议重新运行 deploy_execute.bat"
                $issues++
            }
        }
    } else {
        Write-Fail "未部署 — 请运行 deploy_execute.bat"
        $issues++
    }

    # 3. settings.json 结构校验
    Write-Host ""
    Write-Host "  [3/6] settings.json 结构校验" -ForegroundColor DarkCyan
    $valid = Invoke-ConfigValidate -jsonPath $DeployedJson
    if (-not $valid) { $issues++ }

    # 4. CLAUDE.md 内存审计
    Write-Host ""
    Write-Host "  [4/6] CLAUDE.md 内存审计" -ForegroundColor DarkCyan
    if (Test-Path $DeployedMd) {
        $lines = (Get-Content $DeployedMd).Count
        if ($lines -le 200) {
            Write-Ok "CLAUDE.md 行数: $lines / 200"
        } else {
            Write-Fail "CLAUDE.md 行数: $lines / 200  (超限)"
            $issues++
        }
    } else {
        Write-Warn "CLAUDE.md 未部署"
        $issues++
    }

    # 5. Skills 数量
    Write-Host ""
    Write-Host "  [5/6] Skills 清单" -ForegroundColor DarkCyan
    if (Test-Path $SkillsDir) {
        $count = (Get-ChildItem -Path $SkillsDir -Filter "SKILL.md" -Recurse).Count
        if ($count -gt 0) {
            Write-Ok "已安装 $count 个 Skills"
        } else {
            Write-Warn "Skills 目录为空"
        }
    } else {
        Write-Warn "Skills 目录不存在"
    }

    # 6. MCP 配置
    Write-Host ""
    Write-Host "  [6/6] MCP Servers 配置" -ForegroundColor DarkCyan
    $cfg = Read-Json $DeployedJson
    if ($cfg -and $cfg.mcpServers) {
        $serverNames = $cfg.mcpServers.PSObject.Properties.Name
        Write-Ok "已配置: $($serverNames -join ', ')"
        # 检查 npx 可用性
        $npxAvail = $null -ne (Get-Command npx -ErrorAction SilentlyContinue)
        if ($npxAvail) {
            Write-Ok "npx 可用 (MCP 服务器可正常启动)"
        } else {
            Write-Warn "npx 未找到 — 请安装 Node.js"
            $issues++
        }
    } else {
        Write-Warn "未找到 MCP 配置"
    }

    # 汇总
    Write-Host ""
    Write-Host "══════════════════════════════════════════" -ForegroundColor DarkCyan
    if ($issues -eq 0) {
        Write-Host "  ✓  所有检查通过！Claude_up 环境健康。" -ForegroundColor Green
    } else {
        Write-Host "  ⚠  发现 $issues 个问题，请按上方提示处理。" -ForegroundColor Yellow
    }
    Write-Host "══════════════════════════════════════════" -ForegroundColor DarkCyan
    Write-Host ""
}

# ════════════════════════════════════════════════════════════════════════════
# COMMAND: help
# ════════════════════════════════════════════════════════════════════════════
function Invoke-Help {
    Write-Host ""
    Write-Host "  Claude_up Diagnostic CLI" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  用法: .\claude_app.ps1 <command>" -ForegroundColor White
    Write-Host ""
    Write-Host "  命令：" -ForegroundColor White
    Write-Host "    doctor          全量健康检查（推荐首次运行）" -ForegroundColor Gray
    Write-Host "    mcp-check       列出已配置的 MCP 服务器" -ForegroundColor Gray
    Write-Host "    skill-list      枚举所有已安装 Skills" -ForegroundColor Gray
    Write-Host "    config-validate 验证 settings.json 结构" -ForegroundColor Gray
    Write-Host "    memory-audit    检查 CLAUDE.md 行数及 @import" -ForegroundColor Gray
    Write-Host "    deploy-dry-run  对比模板与已部署文件的差异" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  示例：" -ForegroundColor White
    Write-Host "    .\claude_app.ps1 doctor" -ForegroundColor DarkYellow
    Write-Host "    .\claude_app.ps1 deploy-dry-run" -ForegroundColor DarkYellow
    Write-Host ""
}

# ════════════════════════════════════════════════════════════════════════════
# DISPATCH
# ════════════════════════════════════════════════════════════════════════════
switch ($Command) {
    "doctor"          { Invoke-Doctor }
    "mcp-check"       { Write-Header "MCP Check"; Invoke-McpCheck }
    "skill-list"      { Invoke-SkillList }
    "config-validate" {
        Write-Header "Config Validate"
        Write-Host ""
        Write-Host "  [模板] $TemplateJson" -ForegroundColor DarkCyan
        Invoke-ConfigValidate -jsonPath $TemplateJson
        Write-Host ""
        Write-Host "  [已部署] $DeployedJson" -ForegroundColor DarkCyan
        Invoke-ConfigValidate -jsonPath $DeployedJson
        Write-Host ""
    }
    "memory-audit"    { Invoke-MemoryAudit }
    "deploy-dry-run"  { Invoke-DeployDryRun }
    "help"            { Invoke-Help }
    default           { Invoke-Help }
}
