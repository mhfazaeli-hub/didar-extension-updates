@echo off
setlocal
rem Download and verify the versioned installer, then run its setup.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;" ^
  "$temporaryRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\';" ^
  "$work = [IO.Path]::GetFullPath((Join-Path $temporaryRoot ('DidarSetup-' + [Guid]::NewGuid().ToString('N'))));" ^
  "if (-not $work.StartsWith($temporaryRoot, [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid installer directory.' };" ^
  "[IO.Directory]::CreateDirectory($work) | Out-Null;" ^
  "try {" ^
  "$archive = Join-Path $work 'installer.zip';" ^
  "try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 8 -MaximumRedirection 0 -Uri 'https://raw.githubusercontent.com/mhfazaeli-hub/didar-extension-updates/main/versions/0.21.66/Install-Didar-Windows.zip' -OutFile $archive } catch { Invoke-WebRequest -UseBasicParsing -TimeoutSec 12 -MaximumRedirection 0 -Uri 'https://api.github.com/repos/mhfazaeli-hub/didar-extension-updates/contents/versions/0.21.66/Install-Didar-Windows.zip?ref=main' -Headers @{'Accept'='application/vnd.github.raw+json'} -OutFile $archive };" ^
  "$hasher = [Security.Cryptography.SHA256]::Create();" ^
  "try { $hash = [BitConverter]::ToString($hasher.ComputeHash([IO.File]::ReadAllBytes($archive))).Replace('-', '').ToLowerInvariant() } finally { $hasher.Dispose() };" ^
  "if ($hash -ne 'd1b0d22cc520fac629ad4c93d242446e0544c1abd6f7aebff8b58ccf7ba14f97') { throw 'Installer download verification failed.' };" ^
  "$files = Join-Path $work 'files';" ^
  "Expand-Archive -LiteralPath $archive -DestinationPath $files;" ^
  "& (Join-Path $files 'install.ps1');" ^
  "} finally { Remove-Item -LiteralPath $work -Recurse -Force }"
set didarInstallResult=%ERRORLEVEL%
pause
exit /b %didarInstallResult%
