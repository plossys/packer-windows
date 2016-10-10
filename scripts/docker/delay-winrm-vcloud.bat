rem Disable firewall because if we provision through WinRM with packer
rem we can't add the next blocking firewall rule without dropping WinRM connection.
rem Firewall will be turned on in shutdown_command of packer template json.
netsh advfirewall set allprofiles state off

rem Disable-NetFirewallRule for WinRM for first boot in vCloud until guest customization
netsh advfirewall firewall add rule name="vagrant-vcloud-winrm" dir=in action=block protocol=TCP localport=5985

copy a:\enable-winrm-after-customization.bat C:\Users\vagrant\enable-winrm-after-customization.bat

rem schtasks /Create /RU vagrant /RP vagrant /TN enable-winrm /XML a:\enable-winrm-after-customization.xml
schtasks /Create /RU sshd_server /RP D@rj33l1ng /TN enable-winrm-after-customization /XML a:\enable-winrm-after-customization.xml
