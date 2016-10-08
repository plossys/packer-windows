echo on
rem Usage:
rem   bin\test-box-vcloud.bat Jenkins job name = template name without json extension
rem
rem Examples:
rem   bin\test-box-vcloud.bat windows_2016_vcloud
rem   bin\test-box-vcloud.bat --debug windows_2016_vcloud
rem   bin\test-box-vcloud.bat --quick --debug windows_2016_vcloud
rem
set quick=0
set debug=0

if "%1x"=="--quickx" (
  shift
  set quick=1
)
if "%1x"=="--debugx" (
  shift
  set debug=1
)

@set BUILD=%1

@if "%BUILD:~-7%" == "_vcloud" (
  set boxname=%BUILD:~0,-7%
  set template=%BUILD%
  set spec=vcloud
)

@if "%spec%x"=="x" (
  echo Wrong build parameter!
  goto :EOF
)

@echo.
@echo boxname = %boxname%
@echo template = %template%
@echo spec = %spec%
@echo.

set result=0

set tmp_path=boxtest
if exist %tmp_path% rmdir /s /q %tmp_path%

if %quick%==1 goto have_vagrantfile

if exist C:\Users\vagrant\.vagrant.d\Vagrantfile goto :have_vagrantfile
if exist C:\vagrant\resources\Vagrantfile-global (
  copy C:\vagrant\resources\Vagrantfile-global C:\Users\vagrant\.vagrant.d\Vagrantfile
)
:have_vagrantfile

rem tested only with box-provider=vcloud
rem vagrant plugin install vagrant-%spec%

rem vagrant plugin install vagrant-serverspec
if %quick%==1 goto have_uploaded

vagrant box remove %boxname% --provider=%spec%
vagrant box add %boxname% %boxname%_%spec%.box -f
if ERRORLEVEL 1 set result=%ERRORLEVEL%
if ERRORLEVEL 1 goto :done

:have_uploaded
@set vcloud_hostname=YOUR-VCLOUD-HOSTNAME
@set vcloud_username=YOUR-VCLOUD-USERNAME
@set vcloud_password=YOUR-VCLOUD-PASSWORD
@set vcloud_org=YOUR-VCLOUD-ORG
@set vcloud_catalog=YOUR-VCLOUD-CATALOG
@set vcloud_vdc=YOUR-VCLOUD-VDC

if "%VAGRANT_HOME%x"=="x" set VAGRANT_HOME=%USERPROFILE%\.vagrant.d

if exist c:\vagrant\resources\test-box-vcloud-credentials.bat call c:\vagrant\resources\test-box-vcloud-credentials.bat

if %quick%==1 goto :do_test

echo Uploading %boxname%.ovf to vCloud %vcloud_hostname% / %vcloud_org% / %vcloud_catalog% / %boxname%
where /q ovftool || set PATH=%PATH%;c:\Program Files (x86)\VMware\VMware Workstation\OVFTool
@ovftool --acceptAllEulas --vCloudTemplate --overwrite %VAGRANT_HOME%\boxes\%boxname%\0\%spec%\%boxname%.ovf "vcloud://%vcloud_username%:%vcloud_password%@%vcloud_hostname%:443?org=%vcloud_org%&vappTemplate=%boxname%&catalog=%vcloud_catalog%&vdc=%vcloud_vdc%"
if ERRORLEVEL 1 goto :first_upload
goto :test_vagrant_box
:first_upload
@ovftool --acceptAllEulas --vCloudTemplate %VAGRANT_HOME%\boxes\%boxname%\0\%spec%\%boxname%.ovf "vcloud://%vcloud_username%:%vcloud_password%@%vcloud_hostname%:443?org=%vcloud_org%&vappTemplate=%boxname%&catalog=%vcloud_catalog%&vdc=%vcloud_vdc%"
if ERRORLEVEL 1 goto :error_vcloud_upload

:test_vagrant_box
@echo.
@echo Sleeping 300 seconds for vCloud to finish vAppTemplate import
@echo Tests with 240 seconds still cause a 500 internal error while powering on
@echo a vApp in vCloud. So be patient until we have a better upload
@echo solution that waits until the import is really finished.
@ping 127.0.0.1 -n 300 > nul

:do_test
set result=0

mkdir %tmp_path%
pushd %tmp_path%
call :create_vagrantfile
if %debug%==1 set VAGRANT_LOG=debug
echo USERPROFILE = %USERPROFILE%
if exist %USERPROFILE%\.ssh\known_hosts type %USERPROFILE%\.ssh\known_hosts
del /F %USERPROFILE%\.ssh\known_hosts
if exist %USERPROFILE%\.ssh\known_hosts echo known_hosts still here!!
vagrant up --provider=%spec%
if ERRORLEVEL 1 set result=%ERRORLEVEL%

if %debug%==1 set VAGRANT_LOG=
@echo Sleep 10 seconds
@ping 1.1.1.1 -n 1 -w 10000 > nul

vagrant destroy -f
if ERRORLEVEL 1 set result=%ERRORLEVEL%
popd

if %quick%==1 goto :done

if %debug%==1 set VAGRANT_LOG=debug
vagrant box remove %boxname% --provider=%spec%
if ERRORLEVEL 1 set result=%ERRORLEVEL%

goto :done

:error_vcloud_upload
echo Error Uploading box to vCloud with ovftool!
goto :done

:create_vagrantfile

rem to test if rsync works
if not exist testdir\testfile.txt (
  mkdir testdir
  echo Works >testdir\testfile.txt
)

echo Vagrant.configure('2') do ^|config^| >Vagrantfile
echo   config.vm.define :"tst" do ^|tst^| >>Vagrantfile
echo     tst.vm.box = "%boxname%" >>Vagrantfile
echo     tst.vm.hostname = "tst"
echo     tst.vm.provider :vcloud do ^|vcloud, override^| >>Vagrantfile
echo       vcloud.vapp_prefix = "%boxname%" >>Vagrantfile
echo       vcloud.catalog_name = "%vcloud_catalog%" >>Vagrantfile
echo       override.vm.usable_port_range = 2200..2999 >>Vagrantfile
echo     end >>Vagrantfile
echo     tst.vm.provision :serverspec do ^|spec^| >>Vagrantfile
echo       spec.pattern = '../test/*_%spec%.rb' >>Vagrantfile
echo     end >>Vagrantfile
echo   end >>Vagrantfile
echo end >>Vagrantfile

echo --color >.rspec
echo --format documentation >>.rspec

exit /b

:done
exit /b %result%
