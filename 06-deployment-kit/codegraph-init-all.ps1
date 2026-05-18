# codegraph-init-all.ps1
# Run codegraph init -i on all 4 projects via node directly

$cgJs = "D:\Program Files\nodejs\node_modules\@colbymchenry\codegraph\dist\bin\codegraph.js"

$projects = @(
    "D:\MoonzWorkspace\Claude_up",
    "D:\MoonzWorkspace\Game",
    "D:\MoonzWorkspace\ganganxiangPM",
    "D:\MoonzWorkspace\quant-arena"
)

if (-not (Test-Path $cgJs)) {
    Write-Host "[ERROR] Not found: $cgJs" -ForegroundColor Red
    Write-Host "Run: npm install -g @colbymchenry/codegraph" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] codegraph.js: $cgJs" -ForegroundColor Green

foreach ($proj in $projects) {
    if (-not (Test-Path $proj)) {
        Write-Host "[SKIP] Not found: $proj" -ForegroundColor Yellow
        continue
    }
    Write-Host ""
    Write-Host "=== $proj ===" -ForegroundColor Cyan
    Push-Location $proj
    node $cgJs init -i
    $exitCode = $LASTEXITCODE
    Pop-Location
    if ($exitCode -eq 0) {
        Write-Host "[OK] $proj" -ForegroundColor Green
    } else {
        Write-Host "[WARN] exit $exitCode : $proj" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Done. Verify: node '$cgJs' status" -ForegroundColor Cyan
