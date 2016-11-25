
if not exist "C:\Windows\Temp\7z1604.msi" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://www.7-zip.org/a/7z1604.msi', 'C:\Windows\Temp\7z1604.msi')" <NUL
)
msiexec /qb /i C:\Windows\Temp\7z1604.msi

if "%PACKER_BUILDER_TYPE%" equ "parallels-iso" goto :parallels
if "%PACKER_BUILDER_TYPE%" equ "virtualbox-iso" goto :virtualbox
if "%PACKER_BUILDER_TYPE%" equ "vmware-iso" goto :vmware

rem default is vmware
rem rem goto :done

:vmware

if exist "C:\Users\vagrant\windows.iso" (
rem    move /Y C:\Users\vagrant\windows.iso C:\Windows\Temp
rem don't move, delete!
    del /Y C:\Users\vagrant\windows.iso
)
if not exist "C:\Windows\Temp\windows.iso" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://packages.vmware.com/tools/releases/10.0.9/windows/x64/VMware-tools-windows-10.0.9-3917699.iso', 'C:\Windows\Temp\windows.iso')" <NUL
    cmd /c rmdir /s /q "C:\Program Files\VMWare"
)

cmd /c ""C:\Program Files\7-Zip\7z.exe" x "C:\Windows\Temp\windows.iso" -oC:\Windows\Temp\VMWare\"
cmd /c C:\Windows\Temp\VMWare\setup.exe /S /v"/qn REBOOT=R\"

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

cmd /c ""C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\VBoxGuestAdditions.iso -oC:\Windows\Temp\virtualbox"
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
rem msiexec /qb /x C:\Windows\Temp\7z1604.msi
