param(
    [Parameter(Mandatory=$true)]
    [string]$InstallerPath
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$fixture = Join-Path $repoRoot ".local-test/installer-e2e"
Remove-Item -Recurse -Force $fixture -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $fixture | Out-Null

$projectPath = Join-Path $fixture "project.godot"
$projectLines = @(
    'config_version=5',
    '',
    '[application]',
    'config/name="Installer E2E"',
    '',
    '[editor_plugins]',
    'enabled=PackedStringArray("res://addons/example/plugin.cfg")',
    ''
)
[IO.File]::WriteAllLines($projectPath, $projectLines, (New-Object Text.UTF8Encoding($false)))

$installer = (Resolve-Path $InstallerPath).Path
$resultPath = Join-Path $fixture "result.json"
$proc = Start-Process -FilePath $installer -ArgumentList @('--project', ('"' + $fixture + '"'), '--silent', '--result', ('"' + $resultPath + '"')) -Wait -PassThru
if ($proc.ExitCode -ne 0) { throw "Installer first run failed with exit code $($proc.ExitCode)" }
$result = Get-Content $resultPath -Raw | ConvertFrom-Json
if (-not $result.ok -or -not $result.enabled -or $result.upgraded) { throw "Unexpected first-run result: $(Get-Content $resultPath -Raw)" }

$pluginCfg = Join-Path $fixture "addons/godot_mcp_local/plugin.cfg"
if (-not (Test-Path $pluginCfg)) { throw "Plugin config was not installed" }
$pluginText = Get-Content $pluginCfg -Raw
if ($pluginText -notmatch 'name="Godot MCP Local"') { throw "Installed plugin has unexpected name" }

$projectText = Get-Content $projectPath -Raw
if ($projectText -notmatch [regex]::Escape('res://addons/example/plugin.cfg')) { throw "Existing plugin entry was lost" }
if ($projectText -notmatch [regex]::Escape('res://addons/godot_mcp_local/plugin.cfg')) { throw "Godot MCP Local was not enabled" }

$resultPath2 = Join-Path $fixture "result-upgrade.json"
$proc2 = Start-Process -FilePath $installer -ArgumentList @('--project', ('"' + $fixture + '"'), '--silent', '--result', ('"' + $resultPath2 + '"')) -Wait -PassThru
if ($proc2.ExitCode -ne 0) { throw "Installer upgrade run failed with exit code $($proc2.ExitCode)" }
$result2 = Get-Content $resultPath2 -Raw | ConvertFrom-Json
if (-not $result2.ok -or -not $result2.enabled -or -not $result2.upgraded) { throw "Unexpected upgrade result: $(Get-Content $resultPath2 -Raw)" }

$enabledLine = (Select-String -Path $projectPath -Pattern '^enabled=').Line
$count = ([regex]::Matches($enabledLine, [regex]::Escape('res://addons/godot_mcp_local/plugin.cfg'))).Count
if ($count -ne 1) { throw "Plugin enable entry duplicated: $enabledLine" }

Write-Host "INSTALLER_E2E=PASS"
Write-Host "PROJECT=$fixture"
Write-Host "FILES=$((Get-ChildItem (Join-Path $fixture 'addons/godot_mcp_local') -File -Recurse).Count)"