
::##################################
::Post-OS-Common-Tasks

@echo off

:: Reconfigure Local Security Audit Policy.

auditpol /set /category:"System" /success:enable /failure:enable 
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable 
auditpol /set /category:"Object Access" /success:disable /failure:disable 
auditpol /set /category:"Privilege Use" /success:enable /failure:enable 
auditpol /set /category:"Detailed Tracking" /success:enable /failure:enable 
auditpol /set /category:"Policy Change" /success:enable /failure:enable 
auditpol /set /category:"Account Management" /success:enable /failure:enable 
auditpol /set /category:"DS Access" /success:enable /failure:enable 
auditpol /set /category:"Account Logon" /success:enable /failure:enable

:: Disable Windows firewall.

netSh Advfirewall set allprofiles state off

:: Set Windows automatic updates to never check.

REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1 /f

:: Install Telnet feature for network/port troubleshooting situations

dism /online /Enable-Feature /FeatureName:TelnetClient

:: Disable Intenet Explorer ESC for all users - requires reboot

REG ADD "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /v IsInstalled /t REG_DWORD /d 00000000 /f

REG ADD "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /v IsInstalled /t REG_DWORD /d 00000000 /f

:: Disable UAC - requires reboot.

REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system /v EnableLUA /t REG_DWORD  /d 0 /f

:: Manual reboot required to make UAC and IE ESC changes take effect.

:: Apply standard network interface configuration settings

powershell -command "Get-NetAdapter | Set-NetIPInterface -InterfaceMetric 1"
powershell -command "Get-NetAdapter | Disable-NetAdapterBinding -ComponentID ms_tcpip6"
powershell -command "Get-NetAdapter | Where-Object -FilterScript {$_.Name -match 'SG' -OR $_.Name -match 'Sungard'} | Set-DnsClient -RegisterThisConnectionsAddress:$false"
powershell -command "Get-NetAdapter | Where-Object -FilterScript {$_.Name -match 'Backup' -OR $_.Name -match 'BKUP'} | Disable-NetAdapterBinding -ComponentID ms_server"
powershell -command "Get-NetAdapter | Where-Object -FilterScript {$_.Name -match 'Backup' -OR $_.Name -match 'BKUP'} | Disable-NetAdapterBinding -ComponentID ms_msclient"
powershell -command "Get-NetAdapter | Where-Object -FilterScript {$_.Name -match 'Management' -OR $_.Name -match 'MGMT'} | Set-NetIPInterface -InterfaceMetric 2"
powershell -command "Get-NetAdapter | Where-Object -FilterScript {$_.Name -match 'Backup' -OR $_.Name -match 'BKUP'} | Set-NetIPInterface -InterfaceMetric 3"
REG ADD HKLM\System\CurrentControlSet\Services\TcpIP6\Parameters /v DisabledComponents /t REG_DWORD /d 0xff /f

:: Set App, Security and System event log max size to 32MB, overwrite logs as needed, and prevent guest access.

REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Application /v RestrictGuestAccess /t REG_DWORD  /d 1 /f
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\System /v RestrictGuestAccess /t REG_DWORD  /d 1 /f

powershell -command "Limit-Eventlog -Logname Application -MaximumSize 32MB -OverflowAction OverwriteAsNeeded"
powershell -command "Limit-Eventlog -Logname Security -MaximumSize 32MB -OverflowAction OverwriteAsNeeded"
powershell -command "Limit-Eventlog -Logname System -MaximumSize 32MB -OverflowAction OverwriteAsNeeded"

::WSUS URL update - batch file

reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v WUServer /t REG_SZ /d "http://windowsupdate.sgns.net" /F
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v WUStatusServer /t REG_SZ /d "http://windowsupdate.sgns.net" /F
wuauclt.exe /resetauthorization /detectnow
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
