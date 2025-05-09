# Usage: .\run_all_tests.ps1 <calculator_executable>
param(
    [string]$calc
)

if (-not $calc) {
    Write-Error "Usage: .\run_all_tests.ps1 <calculator_executable>"
    exit 1
}

$phases = @("phase_1", "phase_2", "phase_3", "phase_4", "phase_5")
$scripts = @("test_phase_1.ps1", "test_phase_2.ps1", "test_phase_3.ps1", "test_phase_4.ps1", "test_phase_5.ps1")
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "Running all Math Quest challenge tests..."

for ($i = 0; $i -lt $scripts.Count; $i++) {
    $script = $scripts[$i]
    $phase = $phases[$i]
    Write-Host ""
    Write-Host "[$($i+1)/5] Running $script for phase '$phase'..."
    $scriptPath = Join-Path $scriptDir $script
    & "$scriptPath" $calc
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Test failed in $script."
        exit 1
    }
}

Write-Host ""
Write-Host "All phases passed! Collect your secret phrases above for badge submission."
