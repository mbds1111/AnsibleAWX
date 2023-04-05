# UD Agent install script
#$probe_ip=$args[0]
param($probe_ip)
#$probe_ip = "10.168.11.216"
# add static route to tools subnet if server needs static routes to 1111 network
#$ErrorPreference = 'SilentlyContinue'
#$hop2tools = Get-NetRoute -DestinationPrefix "65.79.161.80/28" | Select-Object -ExpandProperty "NextHop"
#if ($hop2tools) {
#	$res = route add -p 69.164.113.0 mask 255.255.255.0 $hop2tools
#	write-output "INFO::Added route for No hop."
#}
$ErrorPreference = "Continue"
netsh advfirewall firewall add rule name="SungardAS UDAgent Probe Port 2738" dir=in action=allow protocol=TCP localport=2738 remoteip=$probe_ip
if (!$?){
					Write-Output "ERROR::Could not install UD Agent!!."
					Write-Output $_
					Exit (0)
		}
else{ 
        Write-Output "INFO::Firewall rule is added."
    }
cd "C:\sungard_files\UDAgent_11.60-Upgrade"
if (!$?){
					Write-Output "ERROR::Could not install UD Agent!!."
					Write-Output $_
					Exit (0)
		}

msiexec /x `{B7643B11-A60E-4A33-A465-263FEB22113A`} /quiet
msiexec /i ud-agent-win32-x86.msi SETUPTYPE=Enterprise PORT=2738 URL0=$probe_ip URL1=$probe_ip URL2=$probe_ip TIMEOUT=86400 CERTPATH=C:\sungard_files\UDAgent_11.60-Upgrade /quiet
if (!$?){
					Write-Output "ERROR::Could not install UD Agent!!."
					Write-Output $_
					Exit (0)
		}
		else
		{
			Write-Output "INFO::UD Agent installed successfully."
		}
