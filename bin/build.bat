@setlocal
rem Usage:
rem   bin\build.bat Jenkins job name = template name without json extension
rem
rem Examples:
rem   bin\build.bat windows_2016_vcloud
rem
@set debug=

@if "%1x"=="--debugx" (
  shift
  set debug=--debug
)
@set BUILD=%1

@if "%BUILD:~-7%" == "_vmware" (
  set boxname=%BUILD:~0,-7%
  set template=%BUILD:~0,-7%
  set builder=vmware-iso
  set spec=vmware
)
@if "%BUILD:~-7%" == "_vcloud" (
  set boxname=%BUILD:~0,-7%
  set template=%BUILD%
  set builder=vmware-iso
  set spec=vcloud
)
@if "%BUILD:~-11%" == "_virtualbox" (
  set boxname=%BUILD:~0,-11%
  set template=%BUILD:~0,-11%
  set builder=virtualbox-iso
  set spec=virtualbox
)

@if "%spec%x"=="x" (
  echo Wrong build parameter!
  goto :EOF
)

@echo.
@echo boxname = %boxname%
@echo template = %template%
@echo builder = %builder%
@echo spec = %spec%
@echo.

if exist output-%builder% (
  rmdir /S /Q output-%builder%
)
if exist "C:\Windows\system32\config\systemprofile\VirtualBox VMs\packer-%builder%" (
  rmdir /S /Q "C:\Windows\system32\config\systemprofile\VirtualBox VMs\packer-%builder%"
)
if exist "C:\Windows\system32\config\systemprofile\VirtualBox VMs\%template%" (
  rmdir /S /Q "C:\Windows\system32\config\systemprofile\VirtualBox VMs\%template%"
)

packer build --only=%builder% %template%.json
if ERRORLEVEL 1 goto :EOF

if exist bin\test-box-%spec%.bat (
  call bin\test-box-%spec%.bat %debug% %boxname%_%spec%
)
