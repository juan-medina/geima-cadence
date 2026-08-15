param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ArgsToPass
)

$srcRoot = Split-Path $PSScriptRoot -Parent
$repoRoot = Split-Path $srcRoot -Parent
$python = Join-Path $repoRoot ".venv\Scripts\python.exe"

if (-Not (Test-Path $python)) {
    Write-Host "Virtual environment not found. Please create it first." -ForegroundColor Red
    exit 1
}

Write-Host "Running bake_dash_shield.py..."
Push-Location $srcRoot
try {
    & $python "scripts\bake_dash_shield.py" @ArgsToPass
} finally {
    Pop-Location
}
