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

Write-Host "Running build_songs.py..."
Push-Location $srcRoot
try {
    & $python "scripts\build_songs.py" @ArgsToPass
} finally {
    Pop-Location
}
