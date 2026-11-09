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
  "Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/mhfazaeli-hub/didar-extension-updates/main/versions/0.21.51/Install-Didar-Windows.zip' -OutFile $archive;" ^
  "$hasher = [Security.Cryptography.SHA256]::Create();" ^
  "try { $hash = [BitConverter]::ToString($hasher.ComputeHash([IO.File]::ReadAllBytes($archive))).Replace('-', '').ToLowerInvariant() } finally { $hasher.Dispose() };" ^
  "if ($hash -ne '9cbda6fc86708d3d95d696c0a125ae7bc230e5d3063d0aceec0c1e1a93be14c7') { throw 'Installer download verification failed.' };" ^
  "$files = Join-Path $work 'files';" ^
  "Expand-Archive -LiteralPath $archive -DestinationPath $files;" ^
  "& (Join-Path $files 'install.ps1');" ^
  "} finally { Remove-Item -LiteralPath $work -Recurse -Force }"
set didarInstallResult=%ERRORLEVEL%
pause
exit /b %didarInstallResult%
