

$omAgentDir="C:\Program Files\HP\HP BTO Software\bin\win64\"
cd $omAgentDir
if(!$?){
		write-Output "ERROR::OM Agent NOT Found!! Install Failed!!." 
	    Exit 0
	}
#Checking that THREE CORE processes have started...
$ovcCheck=ovc.exe -status ovbbccb | Select-String -Pattern "Running"
if ($ovcCheck -eq $null) {
            Write-Output "ERROR::OVBBCCB ISN'T RUNNING."	
			Exit 0
        }
		else{
				$ovcCheck1=$ovcCheck.ToString().Trim()
				if($ovcCheck1 -split " " -contains "Running"){
				Write-Output "INFO::OVBBCCB is Running."	
			}
		}
if(!$?){
			write-Output "ERROR::OVBBCCB ISN'T RUNNING." 
			Exit 0
		}

$ovcdCheck=ovc.exe -status ovcd | Select-String -Pattern "Running"
if ($ovcdCheck -eq $null) {
            Write-Output "ERROR::OVCD ISN'T RUNNING."	
			Exit 0
        }
		else{
				$ovcdCheck1=$ovcdCheck.ToString().Trim()
				if($ovcdCheck1 -split " " -contains "Running"){
				Write-Output "INFO::OVCD is Running."	
			}
		}
if(!$?){
			write-Output "ERROR::OVCD ISN'T RUNNING." 
			Exit 0
		}

$ovcnfCheck=ovc.exe -status ovconfd | Select-String -Pattern "Running"
if ($ovcnfCheck -eq $null) {
            Write-Output "ERROR::OVCONFD ISN'T RUNNING."	
			Exit 0
        }
		else{
				$ovcnfCheck1=$ovcnfCheck.ToString().Trim()
				if($ovcnfCheck1 -split " " -contains "Running"){
				Write-Output "INFO::OVCONFD is Running."	
			}
		}
if(!$?){
			write-Output "ERROR::OVCONFD ISN'T RUNNING." 
			Exit 0
		}

#Reloading OVCONFCHG
cd "C:\Program Files\HP\HP BTO Software\bin\win64"
ovconfchg
#Checking communication to OMI-BBC on port 383
$bcutl=bbcutil -ping omi-bbc.tools.sgns.net | Select-String -Pattern "status=eServiceOK"
if ($bcutl -eq $null) {
            Write-Output "ERROR::COMM ERROR to OMI GATEWAY"
			Exit 0
        }
		else{
				$bcutl1=$bcutl.ToString().Trim()
				if($bcutl1 -split " " -contains "status=eServiceOK"){
				Write-Output "INFO::PASSED - status=eServiceOK"	
			}
		}
	
if(!$?){
			write-Output "ERROR::COMM ERROR to OMI GATEWAY." 
			Exit 0
		}

#Checking OVCONF for correct values...
ovconfget | Select-String -Pattern "OPC_IP_ADDRESS"
ovconfget | Select-String -Pattern "OPC_NODENAME"
ovconfget | Select-String -Pattern "SERVER_BIND_ADDR"
ovconfget | Select-String -Pattern "CLIENT_BIND_ADDR"
ovconfget | Select-String -Pattern "LOCAL_NODE_NAME"
ovconfget | Select-String -Pattern "SocketPoll"

#Checking for OMI assigned Policies...
ovpolicy -list

#Checking for valid OVCERTs...
$certStatus=ovcert -status | Select-String -Pattern "Status: Certificate is installed"
if ($certStatus -eq $null) {
            Write-Output "ERROR::COMM ERROR to OMI GATEWAY"
			Exit 0
        }
		else{
				$certStatus1=$certStatus.ToString().Trim()
				if($certStatus1 -match "Status: Certificate is installed."){
				Write-Output "INFO::PASSED - Found Trusted Cert"	
			}
		}
	
if(!$?){
			write-Output "ERROR::FAILED - NO CERTS INSTALLED." 
			Exit 0
		}
		
#Checking OMI Agent version
opcagt -list_all_versions
if(!$?){
			write-Output "ERROR::FAILED - NO AGENT IS INSTALLED." 
			Exit 0
		}