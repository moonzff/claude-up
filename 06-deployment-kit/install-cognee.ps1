#Requires -Version 5.1
param(
    [switch]$Execute,
    [string]$DataPath = "D:\MoonzWorkspace\Claude_up\09-cognee"
)

function Write-Step($msg)  { Write-Host "  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "  [OK]      $msg" -ForegroundColor Green }
function Write-Dry($msg)   { Write-Host "  [DRY-RUN] $msg" -ForegroundColor DarkYellow }
function Write-Err($msg)   { Write-Host "  [ERROR]   $msg" -ForegroundColor Red }
function Write-Warn($msg)  { Write-Host "  [WARN]    $msg" -ForegroundColor Yellow }
function Write-Info($msg)  { Write-Host "  [INFO]    $msg" -ForegroundColor DarkGray }

$Mode = if ($Execute) { "EXECUTE" } else { "DRY-RUN" }

Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  Claude_up - cognee Memory Layer Installer" -ForegroundColor Cyan
Write-Host "  Mode: $Mode" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Check Python ---
Write-Step "Step 1: Checking Python..."

$pythonCmd = $null
foreach ($cmd in @("python", "python3", "py")) {
    $ver = & $cmd --version 2>&1
    if ($LASTEXITCODE -eq 0 -and $ver -match "Python (\d+)\.(\d+)") {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        if ($major -eq 3 -and $minor -ge 10) {
            $pythonCmd = $cmd
            Write-Ok "Found: $ver  (cmd: $cmd)"
            break
        } else {
            Write-Warn "Python $ver too old, need 3.10+"
        }
    }
}

if (-not $pythonCmd) {
    Write-Err "Python 3.10+ not found. Install from https://python.org"
    exit 1
}

# --- Step 2: Check pip ---
Write-Step "Step 2: Checking pip..."

$pipVer = & $pythonCmd -m pip --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Ok "pip OK: $pipVer"
} else {
    Write-Err "pip not found. Run: $pythonCmd -m ensurepip --upgrade"
    exit 1
}

# --- Step 3: Check OPENAI_API_KEY ---
Write-Step "Step 3: Checking OPENAI_API_KEY..."

if ($env:OPENAI_API_KEY) {
    $keyLen = $env:OPENAI_API_KEY.Length
    $masked = $env:OPENAI_API_KEY.Substring(0, [Math]::Min(10, $keyLen)) + "..."
    Write-Ok "OPENAI_API_KEY set: $masked"
} else {
    Write-Warn "OPENAI_API_KEY not set. cognee needs it for LLM + embeddings."
    Write-Info "Set via: System Properties -> Advanced -> Environment Variables"
    Write-Info "Name: OPENAI_API_KEY   Value: sk-..."
}

# --- Step 4: Install cognee ---
Write-Step "Step 4: Installing cognee..."

if ($Execute) {
    Write-Step "Running: $pythonCmd -m pip install cognee"
    & $pythonCmd -m pip install cognee
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Install failed. Try manually: pip install cognee"
        exit 1
    }
    Write-Ok "cognee installed"
} else {
    Write-Dry "Would run: $pythonCmd -m pip install cognee"
}

# --- Step 5: Verify ---
Write-Step "Step 5: Verifying cognee..."

if ($Execute) {
    $result = & $pythonCmd -c "import cognee; print(getattr(cognee, '__version__', 'ok'))" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "cognee importable: $result"
    } else {
        Write-Warn "Import check failed - install may still have succeeded"
    }
} else {
    Write-Dry "Would verify: python -c 'import cognee'"
}

# --- Step 6: Create data directory ---
Write-Step "Step 6: Creating data directory: $DataPath"

if ($Execute) {
    if (-not (Test-Path $DataPath)) {
        New-Item -ItemType Directory -Path $DataPath -Force | Out-Null
        Write-Ok "Created: $DataPath"
        $gi = "*.db`n*.db-shm`n*.db-wal`nvector_store/`ngraph_data/`n"
        Set-Content -Path (Join-Path $DataPath ".gitignore") -Value $gi -Encoding ASCII
        Write-Ok "Created .gitignore"
    } else {
        Write-Ok "Already exists: $DataPath"
    }
} else {
    Write-Dry "Would create: $DataPath"
    Write-Dry "Would create: .gitignore"
}

# --- Done ---
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan

if ($Execute) {
    Write-Host "  DONE" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next steps:"
    Write-Host "  1. Deploy updated settings.json:" -ForegroundColor White
    Write-Host "       cd D:\MoonzWorkspace\Claude_up" -ForegroundColor DarkYellow
    Write-Host "       .\06-deployment-kit\install_claude_app.ps1 -Execute" -ForegroundColor DarkYellow
    Write-Host "  2. Restart Claude Code / Cowork" -ForegroundColor White
    Write-Host "  3. Verify in Claude session:" -ForegroundColor White
    Write-Host "       cognee_remember / cognee_recall" -ForegroundColor DarkYellow
} else {
    Write-Host "  DRY-RUN complete - no changes made" -ForegroundColor Yellow
    Write-Host ""
    $selfPath = $MyInvocation.MyCommand.Path
    Write-Host "  To actually install:"
    Write-Host "    powershell -NoProfile -ExecutionPolicy Bypass -File '$selfPath' -Execute" -ForegroundColor DarkYellow
}

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""
