#!/usr/bin/env pwsh
<#
.SYNOPSIS
Build an assembly lesson program.

.DESCRIPTION
Assembles a MASM source file and links it into a CRT-free Windows executable.
Automatically detects the .asm file in the current directory.

.EXAMPLE
./build.ps1
#>

param(
    [switch]$Debug
)

$ErrorActionPreference = "Stop"

# Find the .asm file in the current directory
$asmFile = Get-ChildItem -Filter *.asm -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $asmFile) {
    Write-Error "No .asm file found in the current directory."
    exit 1
}

$objFile = $asmFile.BaseName + ".obj"
$exeFile = $asmFile.BaseName + ".exe"

Write-Host "Building $($asmFile.Name)..." -ForegroundColor Cyan

# Assemble
Write-Host "  Assembling..." -ForegroundColor Gray
ml64 /c /Fo $objFile $asmFile.Name
if ($LASTEXITCODE -ne 0) {
    Write-Error "Assembly failed (exit code $LASTEXITCODE)."
    exit 1
}

# Link
Write-Host "  Linking..." -ForegroundColor Gray
link /subsystem:console /entry:main $objFile kernel32.lib /out:$exeFile
if ($LASTEXITCODE -ne 0) {
    Write-Error "Linking failed (exit code $LASTEXITCODE)."
    exit 1
}

Write-Host "Build successful: $exeFile" -ForegroundColor Green

# Run
if (-not $Debug) {
    Write-Host "Running $exeFile..." -ForegroundColor Gray
    & "./$exeFile"
    $exitStatus = $LASTEXITCODE
    Write-Host "Exit status: $exitStatus" -ForegroundColor Gray
}

