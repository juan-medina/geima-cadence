param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$AudioFile
)

if (-Not (Test-Path ".\.venv")) {
    Write-Host "Virtual environment not found. Please create it first." -ForegroundColor Red
    exit 1
}

if (-Not (Test-Path "scripts\beatmap_generator.py")) {
    Write-Host "Error: scripts\beatmap_generator.py not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Generating beatmap from $AudioFile..."
& .\.venv\Scripts\python.exe scripts\beatmap_generator.py $AudioFile
