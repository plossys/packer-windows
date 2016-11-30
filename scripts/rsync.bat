
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
if not exist "%SEVENZIP_EXE%" echo ==^> ERROR: Failed to install "%SEVENZIP_PATH%" & goto done


:install_rsync
if defined ProgramFiles(x86) (
  set RSYNC_URL=http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/rsync/rsync-3.1.2-1.tar.xz
) else (
  set RSYNC_URL=http://mirrors.kernel.org/sourceware/cygwin/x86/release/rsync/rsync-3.1.2-1.tar.xz
  copy a:\cygpopt-0.dll "C:\Program Files\OpenSSH\bin\cygpopt-0.dll"
)
for %%i in ("%RSYNC_URL%") do set RSYNC_TARXZ=%%~nxi
set RSYNC_TAR=%RSYNC_TARXZ:~0,-3%
set RSYNC_DIR=%TEMP%\rsync
set RSYNC_PATH=%RSYNC_DIR%\%RSYNC_TARXZ%
mkdir %RSYNC_DIR%

pushd %RSYNC_DIR%
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%RSYNC_URL%', '%RSYNC_PATH%')" <NUL
cmd /c ""SEVENZIP_EXE" x %RSYNC_TARXZ%"
cmd /c ""SEVENZIP_EXE" x %RSYNC_TAR%"
copy /Y usr\bin\rsync.exe "C:\Program Files\OpenSSH\bin\rsync.exe"
popd

:done
msiexec /qb /x "%SEVENZIP_PATH%"

rem make symlink for c:/vagrant share
mklink /D "C:\Program Files\OpenSSH\vagrant" "C:\vagrant"
