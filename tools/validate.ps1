# Gate for Welcome to the Board. Stops at the first failure.
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

function Invoke-Checked([string[]]$Command) {
	& $Command[0] $Command[1..($Command.Length - 1)]
	if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Invoke-Checked @("godot", "--headless", "--path", $Root, "--import")
Invoke-Checked @("gdformat", "--check", "src", "tests")
Invoke-Checked @("gdlint", "src", "tests")
Invoke-Checked @(
	"godot", "--headless", "--path", $Root,
	"-s", "addons/gut/gut_cmdln.gd", "-gdir=res://tests", "-gexit"
)
Invoke-Checked @(
	"godot", "--headless", "--path", $Root, "-s", "res://tests/probes/smoke_runner.gd"
)

$Out = Join-Path ([System.IO.Path]::GetTempPath()) ("enet-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $Out | Out-Null
$Port = Get-Random -Minimum 20000 -Maximum 40000
$HostProc = Start-Process -FilePath "godot" -PassThru -NoNewWindow -ArgumentList @(
	"--headless", "--path", $Root, "-s", "res://tests/probes/enet_probe.gd", "--",
	"--role=host", "--port=$Port", "--out=$Out"
)
$Ready = $false
for ($i = 0; $i -lt 100; $i++) {
	if (Test-Path (Join-Path $Out "host_ready")) { $Ready = $true; break }
	if ($HostProc.HasExited) { break }
	Start-Sleep -Milliseconds 100
}
if (-not $Ready) { Write-Error "host did not become ready"; exit 1 }
$ClientA = Start-Process -FilePath "godot" -PassThru -NoNewWindow -ArgumentList @(
	"--headless", "--path", $Root, "-s", "res://tests/probes/enet_probe.gd", "--",
	"--role=client", "--port=$Port", "--out=$Out"
)
$ClientB = Start-Process -FilePath "godot" -PassThru -NoNewWindow -ArgumentList @(
	"--headless", "--path", $Root, "-s", "res://tests/probes/enet_probe.gd", "--",
	"--role=client", "--port=$Port", "--out=$Out"
)
$HostProc.WaitForExit()
$ClientA.WaitForExit()
$ClientB.WaitForExit()
if ($HostProc.ExitCode -ne 0 -or $ClientA.ExitCode -ne 0 -or $ClientB.ExitCode -ne 0) { exit 1 }
Invoke-Checked @("python", "$Root\tools\compare_net_state.py", $Out)
Invoke-Checked @(
	"godot", "--headless", "--path", $Root, "-s", "res://tests/probes/trial_probe.gd"
)

$Perf = if ($env:PERF_DIR) { $env:PERF_DIR } else { Join-Path $Root "build\perf" }
New-Item -ItemType Directory -Force -Path $Perf | Out-Null
& godot --rendering-driver vulkan --rendering-method forward_plus --path $Root `
	--resolution 1280x720 --audio-driver Dummy `
	-s res://tests/probes/perf_audit.gd -- --out="$Perf\report-forward.txt"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& godot --rendering-driver opengl3 --rendering-method gl_compatibility --path $Root `
	--resolution 1280x720 --audio-driver Dummy `
	-s res://tests/probes/perf_audit.gd -- --out="$Perf\report-compatibility.txt"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$Visual = if ($env:VISUAL_QA_DIR) { $env:VISUAL_QA_DIR } else { Join-Path $Root "build\visual-qa" }
New-Item -ItemType Directory -Force -Path $Visual | Out-Null
& godot --rendering-driver opengl3 --rendering-method gl_compatibility --path $Root `
	--resolution 1280x720 --audio-driver Dummy `
	-s res://tests/probes/visual_qa.gd -- --out=$Visual
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output "VALIDATE_PASS"
