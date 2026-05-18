# test-cognee.ps1 - Quick cognee startup check

Write-Host "--- cognee startup test ---" -ForegroundColor Cyan

# 1. Check DASHSCOPE_API_KEY
$apiKey = $env:DASHSCOPE_API_KEY
if ([string]::IsNullOrEmpty($apiKey)) {
    $apiKey = [System.Environment]::GetEnvironmentVariable("DASHSCOPE_API_KEY", "User")
    if (-not [string]::IsNullOrEmpty($apiKey)) {
        $env:DASHSCOPE_API_KEY = $apiKey
    }
}
if ([string]::IsNullOrEmpty($apiKey)) {
    Write-Host "[FAIL] DASHSCOPE_API_KEY is not set" -ForegroundColor Red
    exit 1
} else {
    Write-Host "[OK]   DASHSCOPE_API_KEY is set (length: $($apiKey.Length))" -ForegroundColor Green
}

# 2. Check Python
$py = python --version 2>&1
Write-Host "[OK]   $py" -ForegroundColor Green

# 3. Check cognee installed
$cogneeCheck = python -c "import cognee; print('cognee', cognee.__version__)" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK]   $cogneeCheck" -ForegroundColor Green
} else {
    Write-Host "[FAIL] cognee import failed: $cogneeCheck" -ForegroundColor Red
    exit 1
}

# 4. Check data path writable
$dataPath = "D:\MoonzWorkspace\Claude_up\09-cognee"
if (Test-Path $dataPath) {
    Write-Host "[OK]   data path exists: $dataPath" -ForegroundColor Green
} else {
    Write-Host "[WARN] data path missing: $dataPath" -ForegroundColor Yellow
}

# 5. Try launching MCP server briefly (3s timeout)
Write-Host ""
Write-Host "Starting cognee MCP server (3s test)..." -ForegroundColor Cyan
$env:LLM_API_KEY          = $apiKey
$env:LLM_PROVIDER         = "openai"
$env:LLM_MODEL            = "qwen-plus"
$env:LLM_ENDPOINT         = "https://dashscope.aliyuncs.com/compatible-mode/v1"
$env:EMBEDDING_PROVIDER   = "openai"
$env:EMBEDDING_API_KEY    = $apiKey
$env:EMBEDDING_MODEL      = "text-embedding-v3"
$env:EMBEDDING_ENDPOINT   = "https://dashscope.aliyuncs.com/compatible-mode/v1"
$env:COGNEE_DATA_PATH     = $dataPath

$proc = Start-Process python -ArgumentList "-m", "cognee.mcp" -PassThru -NoNewWindow -RedirectStandardError "$env:TEMP\cognee_test_err.txt"
Start-Sleep -Seconds 3

if (-not $proc.HasExited) {
    Write-Host "[OK]   MCP server started (PID $($proc.Id)), stopping..." -ForegroundColor Green
    $proc.Kill()
} else {
    $errOut = Get-Content "$env:TEMP\cognee_test_err.txt" -ErrorAction SilentlyContinue
    Write-Host "[FAIL] MCP server exited early. Stderr:" -ForegroundColor Red
    Write-Host $errOut -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[PASS] cognee looks good." -ForegroundColor Green
