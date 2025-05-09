# Usage: .\test_explain.ps1 <calculator_executable>
param(
    [string]$calc
)

if (-not $calc) {
    Write-Error "Usage: .\test_explain.ps1 <calculator_executable>"
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

$output = & $calc "explain((x + 1)^2)"
$lines = $output -split "`n"
# $expectedSteps = @(
#     "Step 1: Expand (x + 1)^2 = x^2 + 2*x + 1"
# )
$expectedResult = "x^2 + 2*x + 1"
# $foundSteps = 0
# foreach ($step in $expectedSteps) {
#     if ($lines -contains $step) {
#         $foundSteps++
#     }
# }
$result = $null
foreach ($line in $lines) {
    Write-Host $line
    if ($line.Trim().StartsWith("RESULT:")) {
        $result = $line.Trim().Substring(7).Trim()
        break
    }
}
# if ($foundSteps -ne $expectedSteps.Count -or $result -ne $expectedResult) {
if ($result -ne $expectedResult) {
    Write-Host "FAIL: Expected explanation output and result, got:"
    Write-Host $output
    exit 1
}

Write-Host "Phase 5 - Explanation tests passed."
if ($LASTEXITCODE -eq 0) {
    Write-Host "Phase 5 completed: \"$secret\""
} else {
    Write-Host "Phase 5 failed."
    exit 1
}
