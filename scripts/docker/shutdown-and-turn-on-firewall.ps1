Write-Host "Turning on Firewall in 10 seconds ..."
Start-Sleep 10
netsh advfirewall set allprofiles state on

Write-Host "Shutting down system ..."
shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"
