param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ArgsToPass
)

if (-Not (Test-Path ".\.venv")) {
    Write-Host "Virtual environment not found. Please create it first." -ForegroundColor Red
    exit 1
}

Write-Host "Running bake_top_fade.py..."
& .\.venv\Scripts\python.exe scripts\bake_top_fade.py @ArgsToPass
