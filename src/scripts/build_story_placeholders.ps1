param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ArgsToPass
)

if (-Not (Test-Path ".\.venv")) {
    Write-Host "Virtual environment not found. Please create it first." -ForegroundColor Red
    exit 1
}

Write-Host "Running build_story_placeholders.py..."
& .\.venv\Scripts\python.exe scripts\build_story_placeholders.py @ArgsToPass
