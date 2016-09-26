Set-ExecutionPolicy Bypass -scope Process
New-Item -Type Directory -Path "$($env:ProgramFiles)\docker"
wget -outfile $env:TEMP\docker-1.13.0-dev.zip "https://master.dockerproject.com/windows/amd64/docker-1.13.0-dev.zip"
Expand-Archive -Path $env:TEMP\docker-1.13.0-dev.zip -DestinationPath $env:TEMP -Force
copy $env:TEMP\docker\*.exe $env:ProgramFiles\docker
Remove-Item $env:TEMP\docker-1.13.0-dev.zip
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$($env:ProgramFiles)\docker", [EnvironmentVariableTarget]::Machine)
$env:Path = $env:Path + ";$($env:ProgramFiles)\docker"
. dockerd --register-service -H npipe:// -H 0.0.0.0:2375 -G docker

Start-Service Docker

Write-Host "Installing WindowsServerCore container image..."
& "C:\Program Files\docker\docker.exe" pull microsoft/windowsservercore:10.0.14393.206
& "C:\Program Files\docker\docker.exe" tag microsoft/windowsservercore:10.0.14393.206 microsoft/windowsservercore:latest

if ((get-windowsfeature Hyper-V | where installed).count) {
  Write-Host "Installing NanoServer container image..."
  & "C:\Program Files\docker\docker.exe" pull microsoft/nanoserver:10.0.14393.206
  & "C:\Program Files\docker\docker.exe" tag microsoft/nanoserver:10.0.14393.206 microsoft/nanoserver:latest
} else {
  Write-Host "Skipping NanoServer container image"
}