# Downloads the official foobar2000 SDK 2026-10-01 into ./sdk (same content as
# the "foobar2000 SDK-2026-10-01" reference folder used during development).
#
# Usage (PowerShell, from the repository root):
#   powershell -ExecutionPolicy Bypass -File .\setup-sdk.ps1
#
# Requires 7-Zip (https://www.7-zip.org/) on PATH, or winget install 7zip.7zip.

$ErrorActionPreference = "Stop"

$SdkUrl = "https://www.foobar2000.org/downloads/SDK-2026-10-01.7z"
$Zip = Join-Path $env:TEMP "fb2k_sdk.7z"
$Extract = Join-Path $env:TEMP "fb2k_sdk_extract"

Write-Host "Downloading $SdkUrl ..."
Invoke-WebRequest -Uri $SdkUrl -OutFile $Zip

if (Test-Path $Extract) { Remove-Item $Extract -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Extract | Out-Null

Write-Host "Extracting ..."
& 7z x $Zip -o"$Extract" -y | Out-Null

$root = $Extract
if (-not (Test-Path "$root\pfc\pfc.vcxproj")) {
    $root = Get-ChildItem $Extract -Directory |
        Where-Object { Test-Path "$($_.FullName)\pfc\pfc.vcxproj" } |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $root) { throw "Unexpected SDK archive layout" }

if (Test-Path "sdk") { Remove-Item "sdk" -Recurse -Force }
New-Item -ItemType Directory -Force -Path "sdk" | Out-Null
Get-ChildItem $root | ForEach-Object { Copy-Item $_.FullName -Destination "sdk\" -Recurse -Force }

if (-not (Test-Path "sdk\foobar2000\SDK\foobar2000_SDK.vcxproj")) {
    throw "foobar2000_SDK.vcxproj missing after extraction"
}

Write-Host "SDK ready at .\sdk - open foo_amr.sln in Visual Studio 2022."
