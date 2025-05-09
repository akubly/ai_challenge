# Usage: .\test_algebraic.ps1 <calculator_executable>
param(
    [string]$calc
)

if (-not $calc) {
    Write-Error "Usage: .\test_algebraic.ps1 <calculator_executable>"
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

$output = & $calc "(8 - 2) * (5 + 1)"
$result = Get-CalcResult $output
if ($result -ne "36") {
    Write-Host "FAIL: Expected 36, got $result ((8 - 2) * (5 + 1))"
    exit 1
}

$output = & $calc "9^2"
$result = Get-CalcResult $output
if ($result -ne "81") {
    Write-Host "FAIL: Expected 81, got $result (9^2)"
    exit 1
}

$output = & $calc "sqrt(25) + cbrt(8)"
$result = Get-CalcResult $output
if ($result -ne "7") {
    Write-Host "FAIL: Expected 7, got $result (sqrt(25) + cbrt(8))"
    exit 1
}

$output = & $calc "e^(2.5 - sqrt(2))"
$result = Get-CalcResult $output
if ($result -ne "2.961768") {
    Write-Host "FAIL: Expected 2.961768, got $result (e^(2.5 - sqrt(2)))"
    exit 1
}

$output = & $calc "log(42.42 * sqrt(3.14))"
$result = Get-CalcResult $output
if ($result -ne "1.876035") {
    Write-Host "FAIL: Expected 1.876035, got $result (log(42.42 * sqrt(3.14)))"
    exit 1
}

$output = & $calc "ln(7.77 + 2.22^2)"
$result = Get-CalcResult $output
if ($result -ne "2.541476") {
    Write-Host "FAIL: Expected 2.541476, got $result (ln(7.77 + 2.22^2))"
    exit 1
}

$output = & $calc "3.5 * 2.1"
$result = Get-CalcResult $output
if ($result -ne "7.35") {
    Write-Host "FAIL: Expected 7.35, got $result (3.5 * 2.1)"
    exit 1
}

$output = & $calc "sqrt(2)"
$result = Get-CalcResult $output
if ($result -ne "1.414214") {
    Write-Host "FAIL: Expected 1.414214, got $result (sqrt(2))"
    exit 1
}

$output = & $calc "log(2.718282)"
$result = Get-CalcResult $output
if ($result -ne "0.434295") {
    Write-Host "FAIL: Expected 0.434295, got $result (log(2.718282))"
    exit 1
}

$output = & $calc "ln(2.718282)"
$result = Get-CalcResult $output
if ($result -ne "1") {
    Write-Host "FAIL: Expected 1, got $result (ln(2.718282))"
    exit 1
}

Write-Host "Phase 2 - Algebraic expression tests passed."

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$getSecretPath = Join-Path $scriptDir "get_secret.exe"
$calcPath = (Resolve-Path $calc).Path
$secret = & $getSecretPath 2 $calcPath | Out-String
$secret = $secret -replace "\r|\n", ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "Phase 2 completed: ""$secret"""
} else {
    Write-Host "Phase 2 failed."
    exit 1
}
