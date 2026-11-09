param(
    [string]$ZipPath
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$addonRoot = Join-Path $projectRoot 'WildProfessions'
$tocPath = Join-Path $addonRoot 'WildProfessions.toc'
if (-not (Test-Path -LiteralPath $tocPath)) { throw 'Missing WildProfessions.toc' }

$toc = Get-Content -LiteralPath $tocPath
$interface = ($toc | Where-Object { $_ -match '^## Interface:' } | Select-Object -First 1) -replace '^## Interface:\s*', ''
$tocVersion = ($toc | Where-Object { $_ -match '^## Version:' } | Select-Object -First 1) -replace '^## Version:\s*', ''
if ($interface -ne '16001') { throw "Expected Interface 16001, got '$interface'" }
if ($tocVersion -ne '1.2.0-test.6') { throw "Expected testing version 1.2.0-test.6, got '$tocVersion'" }

$listedLua = @($toc | Where-Object { $_ -match '\.lua$' })
if ($listedLua.Count -eq 0) { throw 'TOC has no Lua files' }
foreach ($entry in $listedLua) {
    if (-not (Test-Path -LiteralPath (Join-Path $addonRoot $entry))) { throw "Missing TOC file: $entry" }
}
if (@($listedLua | Sort-Object -Unique).Count -ne $listedLua.Count) { throw 'Duplicate Lua file entry in TOC' }

if ($toc -match '^## (OptionalDeps|Dependencies):') { throw 'Unexpected external addon dependency in TOC' }
$core = Get-Content -LiteralPath (Join-Path $addonRoot 'Core.lua') -Raw
if ($core -notmatch 'WP\.version\s*=\s*"1\.2\.0-test\.6"') { throw 'Core version does not match TOC' }
$integration = Get-Content -LiteralPath (Join-Path $addonRoot 'Integration.lua') -Raw
if ($integration -notmatch '_G\.NaowhForeverProfessions') { throw 'NaowhForever host detection is missing' }
if ($integration -notmatch 'ProfessionsFrame') { throw 'Native profession pane integration is missing' }
if ($integration -notmatch 'EllesmereUI') { throw 'EllesmereUI compatibility diagnostics are missing' }
$ui = Get-Content -LiteralPath (Join-Path $addonRoot 'UI.lua') -Raw
if ($ui -match 'SetMinResize') { throw 'Unsupported SetMinResize call remains in UI.lua' }
if ($ui -notmatch 'SetResizeBounds') { throw 'Forever-supported resize bounds API is missing' }
$allLua = (Get-ChildItem -LiteralPath $addonRoot -Filter '*.lua' -File | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }) -join "`n"
if ($allLua -match 'ProfessionsFrame\s*:\s*(SetPoint|SetParent|SetScale|SetMovable|SetResizable|StartMoving)\s*\(') {
    throw 'WildProfessions must not mutate Blizzard ProfessionsFrame geometry or parentage'
}

Write-Output "PASS: Interface $interface and version $tocVersion"
Write-Output "PASS: $($listedLua.Count) TOC Lua files exist exactly once"
Write-Output 'PASS: no hard NaowhForever or EllesmereUI dependency'
Write-Output 'PASS: native pane, Naowh pane, and EUI compatibility checks present'
Write-Output 'PASS: no direct protected ProfessionsFrame geometry/parent mutation'

if ($ZipPath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $ZipPath))
    try {
        $entries = @($zip.Entries | ForEach-Object { $_.FullName })
        if (-not ($entries -contains 'WildProfessions/WildProfessions.toc')) { throw 'ZIP is missing the addon root folder or TOC' }
        foreach ($entry in $listedLua) {
            if (-not ($entries -contains "WildProfessions/$entry")) { throw "ZIP is missing $entry" }
        }
        Write-Output "PASS: ZIP structure and integrity ($($zip.Entries.Count) entries)"
    }
    finally { $zip.Dispose() }
}


