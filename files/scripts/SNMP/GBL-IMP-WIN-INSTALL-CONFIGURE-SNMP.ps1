#Install SNMP Feature 
Write-Output "INFO::Verify SNMP Service"
Get-Service -Name snmp*
import-module servermanager	# This command Requires PowerShell 3.0 or higher
Get-WindowsFeature SNMP-Service
Write-Output "INFO::Install-WindowsFeature SNMP-Service -IncludeManagementTools - has been run to install SNMP Service"
Install-WindowsFeature SNMP-Service -IncludeManagementTools # This line installs SNMP with Managment Tools 2012 and above
#Restart service to complete install 
Write-Output "INFO:Restart SNMP Services"
Restart-Service -Name SNMP 
#Set support contact
#$sysContact = "sas.esupport@sungardas.com Phone +1 (800) 441-1181" # SETS SNMP AGENT CONTACT DETAILS
#reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent" /v sysContact /t REG_SZ /d $sysContact /f | Out-Null
#Write-Output "INFO::Sys Contact has been set as" $sysContact
#Configure to accept traps from any host
reg delete ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers\") /v 1 /f | Out-Null
Write-Output "INFO::SNMP has been set to accept traps from any host"

#CONFIGURE SNMP COMMUNITY SECURITY AND DEFINE TRAP VARIABLES

$community = "T!R`$DiM&5a3" # The ` before the $ treats $ as text rather than a special character otherwise value is set as T!R&5a3
$community2 = "4v4!L^B1L1ty" 
#US Trap Exploders
$numtraps = 4
$trap1 = "64.238.199.208"
$trap2 = "213.212.65.208"
$trap3 = "64.238.199.200"
$trap4 = "213.212.65.200"
#Add SNMP trap destinations under SunG@rd!
$trapname = "SunG@rd!"

# configure Security Tab Community String
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $community /t REG_DWORD /d 8 /f | Out-Null # Sets to READ WRITE
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $community2 /t REG_DWORD /d 4 /f | Out-Null # Sets to READ ONLY

Write-Output "INFO::Community strings have been set as" $community "RW and" $community2 "RO"

# CONFIGURE SNMP TRAPS 
if ($numtraps -eq 2)
{
	# configure Traps Tab Community name and Trap Destinations
	reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $trapname) /v 1 /t REG_SZ /d $trap1 /f | Out-Null
	reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $trapname) /v 2 /t REG_SZ /d $trap2 /f | Out-Null

	Write-Output "INFO::Traps have been set as" $trap1 "and " $trap2 "under Trap Name" $trapname
}
Elseif ($numtraps -eq 4)
{
	# configure Traps Tab Community name and Trap Destinations
	reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $trapname) /v 1 /t REG_SZ /d $trap1 /f | Out-Null
	reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $trapname) /v 2 /t REG_SZ /d $trap2 /f | Out-Null
	reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $trapname) /v 3 /t REG_SZ /d $trap3 /f | Out-Null
	reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $trapname) /v 4 /t REG_SZ /d $trap4 /f | Out-Null

	Write-Output "INFO::Traps have been set as" $trap1 "," $trap2 "," $trap3 "and " $trap4 "under Trap Name" $trapname
}
}
