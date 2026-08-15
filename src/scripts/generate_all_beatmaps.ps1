param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ExtraArgs
)

$srcRoot = Split-Path $PSScriptRoot -Parent
$repoRoot = Split-Path $srcRoot -Parent
$python = Join-Path $repoRoot ".venv\Scripts\python.exe"

if (-Not (Test-Path $python)) {
    Write-Host "Virtual environment not found. Please create it first." -ForegroundColor Red
    exit 1
}

if (-Not (Test-Path (Join-Path $srcRoot "scripts\beatmap_generator.py"))) {
    Write-Host "Error: scripts\beatmap_generator.py not found!" -ForegroundColor Red
    exit 1
}

$songsDir = Join-Path $srcRoot "data\assets\songs"
$songs = Get-ChildItem -Path $songsDir -Filter "*.ogg" | Sort-Object Name
if ($songs.Count -eq 0) {
    Write-Host "No .ogg files found in $songsDir." -ForegroundColor Red
    exit 1
}

Write-Host "Generating beatmaps for $($songs.Count) song(s)..."
Push-Location $srcRoot
try {
    foreach ($song in $songs) {
        Write-Host ""
        Write-Host "=== $($song.Name) ===" -ForegroundColor Cyan
        & $python "scripts\beatmap_generator.py" $song.FullName @ExtraArgs
    }
} finally {
    Pop-Location
}
