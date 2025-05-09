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

function Write-GraphCSV {
    param(
        [string[]]$lines,
        [string]$csvPath
    )
    foreach ($line in $lines) {
        if ($line.Trim()) {
            $line | Out-File -Encoding ascii -FilePath $csvPath -Append
        }
    }
}

function Show-GraphPlot {
    param(
        [string]$csvPath,
        [string]$title
    )
    $showPlot = $false
    $response = Read-Host "Would you like to see a graph of the results for '$title'? (y/n)"
    if ($response -match '^(y|Y)') {
        $showPlot = $true
    }
    if ($showPlot) {
        $pyPath = [System.IO.Path]::ChangeExtension($csvPath, ".py")
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
plt.title("{title}")
plt.grid(True)
plt.show()
'@ -replace "\{csv\}", $csvPath -replace "\{title\}", $title | Set-Content -Encoding ascii -Path $pyPath
        python $pyPath
        if (Test-Path $pyPath) {
            Remove-Item $pyPath -ErrorAction SilentlyContinue
        }
    }

    # Delete the temp CSV file after running
    if (Test-Path $csvPath) {
        Remove-Item $csvPath -ErrorAction SilentlyContinue
    }
}

# Phase 4: Graphing
# Linear: y = 2x + 3
$output = & $calc "table(2*x + 3, x, -2, 2, 1)"
$result = Get-CalcResult $output
$lines = $result -split "`n"
$expectedLinear = @(
    "x,f(x)",
    "-2,-1",
    "-1,1",
    "0,3",
    "1,5",
    "2,7"
)
for ($i = 0; $i -lt $expectedLinear.Count; $i++) {
    if ($lines[$i].Trim() -ne $expectedLinear[$i]) {
        Write-Host "FAIL: Expected $($expectedLinear[$i]), got $($lines[$i])"
        exit 1
    }
}
$csvPathLinear = Join-Path $env:TEMP "linear_graph.csv"
Write-GraphCSV $lines $csvPathLinear
Show-GraphPlot $csvPathLinear "y = 2x + 3"

# Polynomial: y = x^2 - 2x + 1
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
$csvPath = Join-Path $env:TEMP "polynomial_graph.csv"
Write-GraphCSV $lines $csvPath
Show-GraphPlot $csvPath "y = x^2 - 2x + 1"

# Exponential: y = e^x
$output = & $calc "table(exp(x), x, -2, 2, 1)"

$result = Get-CalcResult $output
$lines = $result -split "`n"
$expectedExponential = @(
    "x,f(x)",
    "-2,0.135335283",
    "-1,0.367879441",
    "0,1",
    "1,2.718281828",
    "2,7.389056099"
)
for ($i = 0; $i -lt $expectedExponential.Count; $i++) {
    $actual = $lines[$i].Trim()
    $expectedVal = $expectedExponential[$i]
    if ($i -eq 0) {
        if ($actual -ne $expectedVal) {
            Write-Host "FAIL: Expected $expectedVal, got $actual"
            exit 1
        }
    } else {
        # Compare up to 6 decimal places for floats
        $actualParts = $actual -split ","
        $expectedParts = $expectedVal -split ","
        if ($actualParts[0] -ne $expectedParts[0] -or ([math]::Abs([double]$actualParts[1] - [double]$expectedParts[1]) -gt 0.00001)) {
            Write-Host "FAIL: Expected $expectedVal, got $actual"
            exit 1
        }
    }
}
$csvPathExponential = Join-Path $env:TEMP "exponential_graph.csv"
Write-GraphCSV $lines $csvPathExponential
Show-GraphPlot $csvPathExponential "y = exp(x)"

# Logarithmic: y = log(x)
$output = & $calc "table(log(x), x, 1, 10, 1)"
$result = Get-CalcResult $output
$lines = $result -split "`n"
$expectedLogarithmic = @(
    "x,f(x)",
    "1,0",
    "2,0.30103",
    "3,0.477121",
    "4,0.60206",
    "5,0.698977",
    "6,0.778151",
    "7,0.845098",
    "8,0.903089",
    "9,0.954242",
    "10,1"
)
for ($i = 0; $i -lt $expectedLogarithmic.Count; $i++) {
    $actual = $lines[$i].Trim()
    $expectedVal = $expectedLogarithmic[$i]
    if ($i -eq 0) {
        if ($actual -ne $expectedVal) {
            Write-Host "FAIL: Expected $expectedVal, got $actual"
            exit 1
        }
    } else {
        $actualParts = $actual -split ","
        $expectedParts = $expectedVal -split ","
        if ($actualParts[0] -ne $expectedParts[0] -or ([math]::Abs([double]$actualParts[1] - [double]$expectedParts[1]) -gt 0.00001)) {
            Write-Host "FAIL: Expected $expectedVal, got $actual"
            exit 1
        }
    }
}
$csvPathLogarithmic = Join-Path $env:TEMP "logarithmic_graph.csv"
Write-GraphCSV $lines $csvPathLogarithmic
Show-GraphPlot $csvPathLogarithmic "y = log(x)"


# Trigonometric: y = sin(x)
$output = & $calc "table(sin(x), x, -pi, pi, pi/4)"
$result = Get-CalcResult $output
$lines = $result -split "`n"
$expectedTrig = @(
    "x,f(x)",
    "-3.141592654,0",
    "-2.35619449,-0.707106781",
    "-1.570796327,-1",
    "-0.785398163,-0.707106781",
    "0,0",
    "0.785398163,0.707106781",
    "1.570796327,1",
    "2.35619449,0.707106781",
    "3.141592654,0"
)
for ($i = 0; $i -lt $expectedTrig.Count; $i++) {
    $actual = $lines[$i].Trim()
    $expectedVal = $expectedTrig[$i]
    if ($i -eq 0) {
        if ($actual -ne $expectedVal) {
            Write-Host "FAIL: Expected $expectedVal, got $actual"
            exit 1
        }
    } else {
        $actualParts = $actual -split ","
        $expectedParts = $expectedVal -split ","
        if ([math]::Abs([double]$actualParts[0] - [double]$expectedParts[0]) -gt 0.00001 -or ([math]::Abs([double]$actualParts[1] - [double]$expectedParts[1]) -gt 0.00001)) {
            Write-Host "FAIL: Expected $expectedVal, got $actual"
            exit 1
        }
    }
}
$csvPathTrigonometric = Join-Path $env:TEMP "trigonometric_graph.csv"
Write-GraphCSV $lines $csvPathTrigonometric
Show-GraphPlot $csvPathTrigonometric "y = sin(x)"

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
