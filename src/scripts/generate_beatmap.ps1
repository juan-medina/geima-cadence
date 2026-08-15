param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$AudioFile,

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

# Resolve before Push-Location, so a path relative to the caller's directory
# still points at the right file once the working directory changes to src.
$resolvedAudioFile = Resolve-Path $AudioFile -ErrorAction SilentlyContinue
if (-Not $resolvedAudioFile) {
    Write-Host "Error: audio file not found: $AudioFile" -ForegroundColor Red
    exit 1
}

Write-Host "Generating beatmap from $AudioFile..."
Push-Location $srcRoot
try {
    & $python "scripts\beatmap_generator.py" $resolvedAudioFile.Path @ExtraArgs
} finally {
    Pop-Location
}
