<#
.SYNOPSIS
Assemble and link a single-source Windows x64 lesson program.

.DESCRIPTION
Run in a Visual Studio x64 developer environment. The entry symbol is main.
Select a source explicitly when the directory contains more than one .asm file.
By default, include debug symbols, run the program and return its exit status.
Use -NoDebug to omit debug information and -NoRun to build without running.
These switches are independent; neither option launches a debugger.

.EXAMPLE
..\..\build.ps1 -Source exit.asm -NoRun

.EXAMPLE
..\..\build.ps1 -Source args.asm -NoDebug
#>

param(
    [string]$Source,
    [switch]$NoDebug,
    [switch]$NoRun
)

$ErrorActionPreference = 'Stop'

if ($Source) {
    $asmFile = Get-Item -LiteralPath $Source
    if ($asmFile.PSIsContainer -or $asmFile.Extension -ne '.asm') {
        throw "Source must be an .asm file: $Source"
    }
} else {
    $sources = @(Get-ChildItem -LiteralPath . -Filter '*.asm' -File)
    if ($sources.Count -eq 0) {
        throw 'No .asm file found in the current directory.'
    }
    if ($sources.Count -ne 1) {
        throw 'Multiple .asm files found. Select one with -Source filename.asm.'
    }
    $asmFile = $sources[0]
}

$assembler = Get-Command ml64.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
$linker = Get-Command link.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $assembler -or -not $linker) {
    throw 'Open a Visual Studio x64 developer PowerShell with ml64.exe and link.exe available.'
}

$objFile = [System.IO.Path]::ChangeExtension($asmFile.FullName, '.obj')
$exeFile = [System.IO.Path]::ChangeExtension($asmFile.FullName, '.exe')
$asmArguments = @('/nologo', '/c', "/Fo$objFile")
$linkArguments = @(
    '/nologo', '/machine:x64', '/subsystem:console', '/entry:main',
    '/nodefaultlib', '/incremental:no', $objFile, 'kernel32.lib', "/out:$exeFile"
)

if (-not $NoDebug) {
    $asmArguments += '/Zi'
    $pdbFile = [System.IO.Path]::ChangeExtension($asmFile.FullName, '.pdb')
    $linkArguments += @('/debug', "/pdb:$pdbFile")
}

Write-Host "Assembling $($asmFile.Name)..."
& $assembler.Path @asmArguments $asmFile.FullName
if ($LASTEXITCODE -ne 0) {
    throw "Assembly failed (exit code $LASTEXITCODE)."
}

Write-Host "Linking $($asmFile.BaseName).exe..."
& $linker.Path @linkArguments
if ($LASTEXITCODE -ne 0) {
    throw "Link failed (exit code $LASTEXITCODE)."
}

if ($NoRun) {
    return
}

& $exeFile
$programExitCode = $LASTEXITCODE
Write-Host "Exit status: $programExitCode"
exit $programExitCode
