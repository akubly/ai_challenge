# Usage: .\test_phase_3.ps1 <calculator_executable>
param(
    [string]$calc
)

if (-not $calc) {
    Write-Error "Usage: .\test_phase_3.ps1 <calculator_executable>"
    exit 1
}

function Remove-Whitespace($s) { return ($s -replace "(\s|\r|\n)", "") }

function Get-CalcResult($output) {
    $lines = $output -split "`n"
    $resultIndex = -1
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $trimmedLine = $lines[$i].Trim()
        if ($trimmedLine.StartsWith("RESULT:")) {
            $resultIndex = $i
            break
        }
    }
    if ($resultIndex -ge 0) {
        # Return everything after "RESULT:" (including newlines)
        $resultText = $lines[$resultIndex].Substring($lines[$resultIndex].IndexOf(":") + 1).Trim()
        $rest = $lines[($resultIndex + 1)..($lines.Length - 1)]
        if ($rest) {
            return ($resultText + "`n" + ($rest -join "`n")).Trim()
        } else {
            return $resultText
        }
    }
    return $null
}

# Phase 4: Graphing
# Test: Output a table of (x, y) pairs for a given expression and range
$output = & $calc "table(x^2 - 2*x + 1, x, -2, 2, 1)"
$result = Get-CalcResult $output
$lines = $result -split "`n"
$expected = @(
    "x,f(x)",
    "-2,9",
    "-1,4",
    "0,1",
    "1,0",
    "2,1"
)

for ($i = 0; $i -lt $expected.Count; $i++) {
    if ($lines[$i].Trim() -ne $expected[$i]) {
        Write-Host "FAIL: Expected $($expected[$i]), got $($lines[$i])"
        exit 1
    }
}

# Generate a CSV of the graphing output
$csvPath = Join-Path $env:TEMP "phase3_graph.csv"
foreach ($line in $lines) {
    if ($line.Trim()) {
        $line | Out-File -Encoding ascii -FilePath $csvPath -Append
    }
}

# Check for python, install if missing
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python not found. Attempting to install via winget..."
    winget install -e --id Python.Python.3
}

# Wait for python to be available
$maxTries = 10
for ($try = 0; $try -lt $maxTries; $try++) {
    if (Get-Command python -ErrorAction SilentlyContinue) { break }
    Start-Sleep -Seconds 2
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python could not be installed automatically. Please install Python 3 manually to enable graphing."
    exit 0
}

# Ensure matplotlib is installed
$matplotlibInstalled = $false
try {
    python -m pip show matplotlib | Out-Null
    $matplotlibInstalled = $true
} catch {
    $matplotlibInstalled = $false
}
if (-not $matplotlibInstalled) {
    Write-Host "matplotlib not found. Attempting to install..."
    python -m pip install matplotlib
}

# Wait for matplotlib to be available
for ($try = 0; $try -lt $maxTries; $try++) {
    try {
        python -m pip show matplotlib | Out-Null
        $matplotlibInstalled = $true
        break
    } catch {
        $matplotlibInstalled = $false
    }
    Start-Sleep -Seconds 2
}
if (-not $matplotlibInstalled) {
    Write-Host "matplotlib could not be installed automatically. Please install matplotlib manually to enable graphing."
    exit 0
}

# Write out the contents of the CSV file
$csvContent = Get-Content -Path $csvPath
Write-Host "CSV content:"
foreach ($line in $csvContent) {
    Write-Host $line
}

# Ask user if they want to see the plot
$showPlot = $false
$response = Read-Host "Would you like to see a graph of the results (Will install python if missing)? (y/n)"
if ($response -match '^(y|Y)') {
    $showPlot = $true
}

if ($showPlot) {
    # Write python plotting script to temp file
    $pyPath = Join-Path $env:TEMP "phase3_plot.py"
    @'
import csv
import matplotlib.pyplot as plt
x = []
y = []
with open(r"{csv}") as f:
    reader = csv.DictReader(f)
    for row in reader:
        x.append(float(row["x"]))
        y.append(float(row["f(x)"]))
plt.plot(x, y, marker="o")
plt.xlabel("x")
plt.ylabel("y")
plt.title("y = x^2 - 2x + 1")
plt.grid(True)
plt.show()
'@ -replace "\{csv\}", $csvPath | Set-Content -Encoding ascii -Path $pyPath

    # Run the plot
    python $pyPath

    # Delete the temp python file after running
    if (Test-Path $pyPath) {
        Remove-Item $pyPath -ErrorAction SilentlyContinue
    }
}
# Delete the temp CSV file after running
if (Test-Path $csvPath) {
    Remove-Item $csvPath -ErrorAction SilentlyContinue
}

Write-Host "Phase 3 - Graphing tests passed."

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$getSecretPath = Join-Path $scriptDir "get_secret.exe"
$calcPath = (Resolve-Path $calc).Path
$secret = & $getSecretPath 3 $calcPath | Out-String
$secret = $secret -replace "\r|\n", ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "Phase 3 completed: ""$secret"""
} else {
    Write-Host "Phase 3 failed."
    exit 1
}
