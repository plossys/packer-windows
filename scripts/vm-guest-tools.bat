
:install_sevenzip
if defined ProgramFiles(x86) (
  set SEVENZIP_URL=http://www.7-zip.org/a/7z1604-x64.msi
) else (
  set SEVENZIP_URL=http://www.7-zip.org/a/7z1604.msi
)
for %%i in ("%SEVENZIP_URL%") do set SEVENZIP_MSI=%%~nxi
set SEVENZIP_DIR=%TEMP%\sevenzip
set SEVENZIP_PATH=%SEVENZIP_DIR%\%SEVENZIP_MSI%


if not exist "%SEVENZIP_PATH%" (
  mkdir "%SEVENZIP_DIR%"
  echo ==^> Downloading "%SEVENZIP_URL%" to "%SEVENZIP_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%SEVENZIP_URL%', '%SEVENZIP_PATH%')" <NUL
)
msiexec /qb /i "%SEVENZIP_PATH%"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%SEVENZIP_PATH%"
set SEVENZIP_EXE="%ProgramFiles%\7-Zip\7z.exe"
if not exist "%SEVENZIP_EXE%" echo ==^> ERROR: Failed to install "%SEVENZIP_PATH%" & goto EOF

:install_vm-guest-tools
if "%PACKER_BUILDER_TYPE%" equ "parallels-iso" goto :parallels
if "%PACKER_BUILDER_TYPE%" equ "virtualbox-iso" goto :virtualbox
if "%PACKER_BUILDER_TYPE%" equ "vmware-iso" goto :vmware

rem default is vmware
rem rem goto :done

:vmware

rem don't move, download! actual we need VMWare-tools 10.0.9 or greater for the vCloud
rem if exist "C:\Users\vagrant\windows.iso" (
rem    move /Y C:\Users\vagrant\windows.iso C:\Windows\Temp
rem )
set VMWARE_TOOLS_URL=https://packages.vmware.com/tools/releases/10.0.9/windows/x64/VMware-tools-windows-10.0.9-4449150.iso
set VMWARE_TOOLS_DIR=%TEMP%\vmware
set VMWARE_TOOLS_ISO=%VMWARE_TOOLS_DIR%\windows.iso
set VMWARE_TOOLS_SETUP=%VMWARE_TOOLS_DIR%\setup.exe

if not exist "%VMWARE_TOOLS_ISO%" (
    mkdir %VMWARE_TOOLS_DIR%
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%VMWARE_TOOLS_URL%', '%VMWARE_TOOLS_ISO%')" <NUL
    cmd /c rmdir /s /q "C:\Program Files\VMWare"
)

cmd /c ""%SEVENZIP_EXE%" x "%VMWARE_TOOLS_ISO%" -o%VMWARE_TOOLS_DIR%"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: cmd /c ""%SEVENZIP_EXE%" x "%VMWARE_TOOLS_ISO%" -o%VMWARE_TOOLS_DIR%"
if not exist "%VMWARE_TOOLS_SETUP" echo ==^> Unable to unzip "%VMWARE_TOOLS_ISO%" & goto done
cmd /c %VMWARE_TOOLS_SETUP% /S /v"/qn REBOOT=R\"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%VMWARE_TOOLS_SETUP%" /S /v "/qn REBOOT=R\"
goto :done

:virtualbox

:: There needs to be Oracle CA (Certificate Authority) certificates installed in order
:: to prevent user intervention popups which will undermine a silent installation.
cmd /c certutil -addstore -f "TrustedPublisher" A:\oracle-cert.cer

if exist "C:\Users\vagrant\VBoxGuestAdditions.iso" (
    move /Y C:\Users\vagrant\VBoxGuestAdditions.iso C:\Windows\Temp
)

if not exist "C:\Windows\Temp\VBoxGuestAdditions.iso" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://download.virtualbox.org/virtualbox/5.1.8/VBoxGuestAdditions_5.1.8.iso', 'C:\Windows\Temp\VBoxGuestAdditions.iso')" <NUL
)

cmd /c ""%SEVENZIP_EXE%" x C:\Windows\Temp\VBoxGuestAdditions.iso -oC:\Windows\Temp\virtualbox"
cmd /c C:\Windows\Temp\virtualbox\VBoxWindowsAdditions.exe /S
rd /S /Q "C:\Windows\Temp\virtualbox"
goto :done

:parallels
if exist "C:\Users\vagrant\prl-tools-win.iso" (
	move /Y C:\Users\vagrant\prl-tools-win.iso C:\Windows\Temp
	cmd /C "C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\prl-tools-win.iso -oC:\Windows\Temp\parallels
	cmd /C C:\Windows\Temp\parallels\PTAgent.exe /install_silent
	rd /S /Q "C:\Windows\Temp\parallels"
)

:done
msiexec /qb /x "%SEVENZIP_PATH%"
