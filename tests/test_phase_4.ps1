# Usage: .\test_phase_4.ps1 <calculator_executable>
param(
    [string]$calc
)

if (-not $calc) {
    Write-Error "Usage: .\test_phase_4.ps1 <calculator_executable>"
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

$output = & $calc "simplify(2*x + 3*x - x)"
$result = Get-CalcResult $output
if ($result -ne (Remove-Whitespace "4*x")) {
    Write-Host "FAIL: Expected 4*x, got $result"
    exit 1
}

$output = & $calc "simplify((x^2 - 1)/(x - 1))"
$result = Get-CalcResult $output
if ($result -ne (Remove-Whitespace "x+1")) {
    Write-Host "FAIL: Expected x+1, got $result"
    exit 1
}

$output = & $calc "simplify(2 + 2)"
$result = Get-CalcResult $output
if ($result -ne (Remove-Whitespace "4")) {
    Write-Host "FAIL: Expected 4, got $result"
    exit 1
}

$output = & $calc "simplify(x + 0)"
$result = Get-CalcResult $output
if ($result -ne (Remove-Whitespace "x")) {
    Write-Host "FAIL: Expected x, got $result"
    exit 1
}

$output = & $calc "simplify(x*1)"
$result = Get-CalcResult $output
if ($result -ne (Remove-Whitespace "x")) {
    Write-Host "FAIL: Expected x, got $result"
    exit 1
}

$output = & $calc "simplify(0*x)"
$result = Get-CalcResult $output
if ($result -ne (Remove-Whitespace "0")) {
    Write-Host "FAIL: Expected 0, got $result"
    exit 1
}

$output = & $calc "simplify((x^2 + 2*x + 1)/(x + 1))"
$result = Get-CalcResult $output
if ($result -ne (Remove-Whitespace "x+1")) {
    Write-Host "FAIL: Expected x+1, got $result"
    exit 1
}

$output = & $calc "simplify((x^2 - x)/(x))"
$result = Get-CalcResult $output
if ($result -ne (Remove-Whitespace "x-1")) {
    Write-Host "FAIL: Expected x-1, got $result"
    exit 1
}

$output = & $calc "simplify((2*x^2 + 4*x)/(2*x))"
$result = Get-CalcResult $output
if ($result -ne (Remove-Whitespace "x+2")) {
    Write-Host "FAIL: Expected x+2, got $result"
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$getSecretPath = Join-Path $scriptDir "get_secret.exe"
$calcPath = (Resolve-Path $calc).Path
$secret = & $getSecretPath 4 $calcPath | Out-String
$secret = $secret -replace "\r|\n", ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "Phase 4 completed: ""$secret"""
} else {
    Write-Host "Phase 4 failed."
    exit 1
}
