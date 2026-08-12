param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ExtraArgs
)

if (-Not (Test-Path ".\.venv")) {
    Write-Host "Virtual environment not found. Please create it first." -ForegroundColor Red
    exit 1
}

if (-Not (Test-Path "scripts\beatmap_generator.py")) {
    Write-Host "Error: scripts\beatmap_generator.py not found!" -ForegroundColor Red
    exit 1
}

$songs = Get-ChildItem -Path "data\assets\songs" -Filter "*.ogg" | Sort-Object Name
if ($songs.Count -eq 0) {
    Write-Host "No .ogg files found in data\assets\songs." -ForegroundColor Red
    exit 1
}

Write-Host "Generating beatmaps for $($songs.Count) song(s)..."
foreach ($song in $songs) {
    Write-Host ""
    Write-Host "=== $($song.Name) ===" -ForegroundColor Cyan
    & .\.venv\Scripts\python.exe scripts\beatmap_generator.py $song.FullName @ExtraArgs
}
