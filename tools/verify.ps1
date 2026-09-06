param(
    [Parameter(Mandatory = $true)][string]$GodotExe,
    [switch]$AllowEngineMismatch
)
# Local validation only. No downloads, no admin, no policy changes.
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$LogRoot = Join-Path $ProjectRoot 'logs'
New-Item -ItemType Directory -Force -Path $LogRoot | Out-Null
if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) {
    throw 'Godot executable not found. Pass the full path to your Godot console executable.'
}
$GodotExe = (Resolve-Path -LiteralPath $GodotExe).Path

function Invoke-GodotChecked {
    param([string[]]$GodotArgs, [string]$LogName, [string]$Marker = '')
    $info = New-Object System.Diagnostics.ProcessStartInfo
    $info.FileName = $GodotExe
    $info.Arguments = (($GodotArgs | ForEach-Object { '"' + ($_ -replace '"', '\"') + '"' }) -join ' ')
    $info.WorkingDirectory = $ProjectRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit(120000)) {
        $process.Kill()
        throw "Timed out after 120 seconds: $LogName. Inspect the project; do not treat this as PASS."
    }
    $process.WaitForExit()
    $text = $stdout.Result + "`n" + $stderr.Result
    $exitCode = $process.ExitCode
    $process.Dispose()
    $text | Set-Content -LiteralPath (Join-Path $LogRoot $LogName) -Encoding UTF8
    Write-Host $text
    if ($exitCode -ne 0 -or $text -match '(?im)(SCRIPT ERROR|Parse Error|(^|\n)ERROR:|TEST_FAIL|TEST_SUITE_FAILED)') {
        throw "Validation failed: $LogName (exit $exitCode)."
    }
    if ($Marker -and -not $text.Contains($Marker)) {
        throw "Expected success marker missing in $LogName."
    }
    return $text
}

$version = Invoke-GodotChecked -GodotArgs @('--version') -LogName 'engine-version.log'
if ($version -notmatch '4\.6\.3\.stable\.official' -or $version -notmatch '7d41c59c4') {
    if (-not $AllowEngineMismatch) {
        throw 'Engine does not match ENGINE_VERSION.txt. Confirm the installed version with the owner. No automatic version changes.'
    }
    Write-Warning 'Explicit engine mismatch override. Record this in the test report; this is not exact-version verification.'
}
Invoke-GodotChecked -GodotArgs @('--headless', '--path', $ProjectRoot, '--import') -LogName 'import.log' | Out-Null
Invoke-GodotChecked -GodotArgs @('--headless', '--path', $ProjectRoot, '--script', 'res://tests/smoke_test.gd') -LogName 'smoke-test.log' -Marker 'ALL_TESTS_PASSED' | Out-Null
Invoke-GodotChecked -GodotArgs @('--headless', '--path', $ProjectRoot, '--quit-after', '120') -LogName 'main-startup.log' | Out-Null
Write-Host 'AUTOMATED_CHECKS_PASSED. Still perform the manual tests in docs/TEST_PLAN.md.' -ForegroundColor Green
