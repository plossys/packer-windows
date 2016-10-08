echo on
rem Usage:
rem   bin\test-box-virtualbox.bat Jenkins job name = template name without json extension
rem
rem Examples:
rem   bin\test-box-virtualbox.bat windows_2016_virtualbox
rem   bin\test-box-virtualbox.bat --debug windows_2016_virtualbox
rem   bin\test-box-virtualbox.bat --quick --debug windows_2016_virtualbox
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

@if "%BUILD:~-11%" == "_virtualbox" (
  set boxname=%BUILD:~0,-11%
  set template=%BUILD:~0,-11%
  set spec=virtualbox
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

if %quick%==1 goto :do_test

rem vagrant plugin install vagrant-serverspec

vagrant box remove %boxname% --provider=%spec%
vagrant box add %boxname% %boxname%_%spec%.box -f
if ERRORLEVEL 1 set result=%ERRORLEVEL%
if ERRORLEVEL 1 goto :done

if "%VAGRANT_HOME%x"=="x" set VAGRANT_HOME=%USERPROFILE%\.vagrant.d

:do_test
set result=0

mkdir %tmp_path%
pushd %tmp_path%
call :create_vagrantfile
echo USERPROFILE = %USERPROFILE%
if exist %USERPROFILE%\.ssh\known_hosts type %USERPROFILE%\.ssh\known_hosts
del /F %USERPROFILE%\.ssh\known_hosts
if exist %USERPROFILE%\.ssh\known_hosts echo known_hosts still here!!
vagrant up --provider=%spec%
if ERRORLEVEL 1 set result=%ERRORLEVEL%

@echo Sleep 10 seconds
@ping 1.1.1.1 -n 1 -w 10000 > nul

vagrant destroy -f
if ERRORLEVEL 1 set result=%ERRORLEVEL%
popd

if %quick%==1 goto :done

vagrant box remove %boxname% --provider=%spec%
if ERRORLEVEL 1 set result=%ERRORLEVEL%

goto :done

:create_vagrantfile

rem to test if rsync / shared folder works
if not exist testdir\testfile.txt (
  mkdir testdir
  echo Works >testdir\testfile.txt
)

echo Vagrant.configure('2') do ^|config^| >Vagrantfile
echo   config.vm.define :"tst" do ^|tst^| >>Vagrantfile
echo     tst.vm.box = "%boxname%" >>Vagrantfile
echo     tst.vm.hostname = "tst"
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
