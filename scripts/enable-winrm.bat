if exist a:\enable-winrm.ps1 (
  powershell -File a:\enable-winrm.ps1
)

rem Enable-NetFirewallRule for WinRM
netsh advfirewall firewall add rule name="Port 5985" dir=in action=allow protocol=TCP localport=5985
