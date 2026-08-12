param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ArgsToPass
)

if (-Not (Test-Path ".\.venv")) {
    Write-Host "Virtual environment not found. Please create it first." -ForegroundColor Red
    exit 1
}

Write-Host "Running bake_dash_shield.py..."
& .\.venv\Scripts\python.exe scripts\bake_dash_shield.py @ArgsToPass
