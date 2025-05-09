# Usage: .\test_basic.ps1 <calculator_executable>
param(
    [string]$calc
)

if (-not $calc) {
    Write-Error "Usage: .\test_basic.ps1 <calculator_executable>"
    exit 1
}

function Remove-Whitespace($s) { return ($s -replace "(\s|\r|\n)", "") }

function Get-CalcResult($output) {
    foreach ($line in $output -split "`n") {
        $trimmedLine = $line.Trim()
        if ($trimmedLine.StartsWith("RESULT:")) {
            return Remove-Whitespace($trimmedLine.Substring(7))
        }
    }
    return $null
}

$output = & $calc "2 + 3 * 4"
$result = Get-CalcResult $output
if ($result -ne "14") {
    Write-Host "FAIL: Expected 14, got $result"
    exit 1
}

$output = & $calc "10 / 2 - 1"
$result = Get-CalcResult $output
if ($result -ne "4") {
    Write-Host "FAIL: Expected 4, got $result"
    exit 1
}

$output = & $calc "2.5 + 3.1"
$result = Get-CalcResult $output
if ($result -ne "5.6") {
    Write-Host "FAIL: Expected 5.6, got $result (2.5 + 3.1)"
    exit 1
}

$output = & $calc "7.2 / 3"
$result = Get-CalcResult $output
if ($result -ne "2.4") {
    Write-Host "FAIL: Expected 2.4, got $result (7.2 / 3)"
    exit 1
}

$output = & $calc "5.5 - 2.2"
$result = Get-CalcResult $output
if ($result -ne "3.3") {
    Write-Host "FAIL: Expected 3.3, got $result (5.5 - 2.2)"
    exit 1
}

$output = & $calc "1.5 * 4.2"
$result = Get-CalcResult $output
if ($result -ne "6.3") {
    Write-Host "FAIL: Expected 6.3, got $result (1.5 * 4.2)"
    exit 1
}

Write-Host "Phase 1 - basic arithmetic tests passed."

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$getSecretPath = Join-Path $scriptDir "get_secret.exe"
$calcPath = (Resolve-Path $calc).Path
$secret = & $getSecretPath 1 $calcPath | Out-String
$secret = $secret -replace "\r|\n", ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "Phase 1 completed: ""$secret"""
}
else {
    Write-Host "Phase 1 failed."
    exit 1
}