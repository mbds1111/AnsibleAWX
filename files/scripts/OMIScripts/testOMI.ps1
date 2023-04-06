#Read Inputs
#$snt_code=$args[0]
#$mgmt_ip=$args[1]
param ($snt_code, $mgmt_ip)
#$snt_code="saot"
#$mgmt_ip="69.164.113.145"
$dir=$Env:windir
#write-output $dir
$omAgentDir="C:\Program Files\HP\HP BTO Software\bin\win64\"


#Copy-Item C:\Windows\System32\drivers\etc\hosts C:\Windows\System32\drivers\etc\hosts.bkp
#Backup host file and adding OMI VIP Address:
Copy-Item "$dir\System32\drivers\etc\hosts" "$dir\System32\drivers\etc\hosts.bkp"
$hostExist=Get-Content "$dir\System32\drivers\etc\hosts" | find "216.203.5.152 omi-bbc.tools.sgns.net"
if(!$hostExist){
		Write-Output "INFO::Host entry is not exist!! Adding entry in to etc\hosts:"
		$hostFile=Get-Content $dir\System32\drivers\etc\hosts
		$hostFile += "216.203.5.152 omi-bbc.tools.sgns.net"
		Set-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value $hostFile -Force
		if (!$?){
					Write-Output "ERROR::Could not add etc\hosts entry."
					Write-Output $_
					Exit (0)
		}
}
#Read HostName
$hostN = hostname
if(!$?){
		write-Output "ERROR::Could not get hostname!!." 
	    Exit 0
	}
$hostName=$hostN.trim()
$fqdn="$hostName.$snt_code.omi.local"
#Validating OM Agent Install Completed...
cd $omAgentDir
if(!$?){
		write-Output "ERROR::Incomplete OM Agent install detected!!." 
	    Exit 0
	}
#Binding IP if SungardAS Management IP exists on Server
$ipcmd=ipconfig /all | sls IPv4
$ipval = $ipcmd | Select-String -Pattern "$mgmt_ip" | Out-String
$ipval1 =$ipval.Trim()
If( ($ipval1 -split ": "-contains "$mgmt_ip") -or ($ipval1 -split ": "-contains "$mgmt_ip(Preferred)")) {
		#BINDING MANAGEMENT IP
        ovconfchg -ns sec.core.auth -clear MANAGER
        ovconfchg -ns sec.core.auth -clear MANAGER_ID
        ovconfchg -ns sec.cm.client -clear CERTIFICATE_SERVER
        ovconfchg -ns sec.cm.client -set MANAGER omi-bbc.tools.sgns.net
        ovconfchg -ns sec.core.auth -set MANAGER_ID 6bb43a90-d44a-428b-8b67-5636070dd029
        ovconfchg -ns sec.cm.client -set CERTIFICATE_SERVER omi-bbc.tools.sgns.net
        ovconfchg -ns eaagt -set OPC_IP_ADDRESS $mgmt_ip
	    ovconfchg -ns eaagt -set OPC_NAMESRV_LOCAL_NAME $fqdn 
		ovconfchg -ns eaagt -set OPC_NODENAME $fqdn
		ovconfchg -ns bbc.cb -set SERVER_BIND_ADDR $mgmt_ip
		ovconfchg -ns bbc.http -set SERVER_BIND_ADDR $mgmt_ip
		ovconfchg -ns bbc.http -set CLIENT_BIND_ADDR $mgmt_ip
		ovconfchg -ns coda.comm -set SERVER_BIND_ADDR $mgmt_ip
		ovconfchg -ns xpl.net -set LOCAL_NODE_NAME $fqdn
		ovconfchg -ns xpl.net -set SocketPoll true
		ovc -kill
		opcagt -cleanstart
		opcagt -status
        if(!$?){
	    	write-Output "ERROR::Could not Run Binding management IP commands." 
    	    Exit 0
	    }

}
else{
		#NO MANAGEMENT IP - NO IP TO BIND
		ovconfchg -ns xpl.net -set LOCAL_NODE_NAME $fqdn
		ovconfchg -ns xpl.net -set SocketPoll true
if(!$?){
		Write-Output "ERROR:: Could not Run set local node name commands. Refer the details below:"
		Write-Output $_
		Exit 0
}

}
#Activate
cd "$omAgentDir\OpC\install"

cscript opcactivate.vbs -srv omi-bbc.tools.sgns.net -cert_srv omi-bbc.tools.sgns.net -f
if(!$?){
		Write-Output "Could not activate OPC"
		Exit 0
}