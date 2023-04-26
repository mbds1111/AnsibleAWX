#!/bin/sh
############################################
#Modified original script for Ansible
############################################
# Error Codes
# 1 - Software not installed properly
# 2 - No OMI VIP in ETC HOSTS file.
# 3 - One (or All) core services aren't running
# 4 - Unable to reach OMI VIP on Port 383
# 5 - No valid cert installed
omdir=/opt/OV/bin/
if [ ! -d "$omdir" ]; then
echo "ERROR::OM Agent NOT Found!! Install Failed!!" && exit 1
else echo "INFO::Install Verified"
fi
echo
omi=$(grep -i -c "216.203.5.152 omi-bbc.tools.sgns.net" /etc/hosts)
if [ "$omi" -ge "1" ]; then
echo "INFO::OMI VIP is added in Host File!" && grep -i "216.203.5.152 omi-bbc.tools.sgns.net" /etc/hosts
else echo "ERROR:: OMI VIP is not added in Host File - ERROR"  && exit 2
fi

echo
echo "INFO::Checking OVC Core Processes..."
/opt/OV/bin/ovc -status |grep CORE
checkovbbccb=$(/opt/OV/bin/ovc -status ovbbccb |grep -c 'Running')
if [[ $checkovbbccb == 0 ]]; then
echo "ERROR::OVBBCCB ISN'T RUNNING!!!" && exit 3
else echo "INFO::OVBBCCB IS RUNNING!!!" >nul
fi
checkovcd=$(/opt/OV/bin/ovc -status ovcd |grep -c 'Running')
if [[ $checkovcd == 0 ]]; then
echo "ERROR::OVCD ISN'T RUNNING!!!" && exit 3
else echo "INFO::OVCD IS RUNNING!!!" >nul
fi
checkovconfd=$(/opt/OV/bin/ovc -status ovconfd |grep -c 'Running')
if [[ $checkovconfd == 0 ]]; then
echo "ERROR::OVCONFD ISN'T RUNNING!!!" && exit 3
else echo "INFO::OVCONFD IS RUNNING!!!" >nul
fi
echo "INFO::All CORE Services are RUNNING!!"
echo

echo "INFO::Checking Connectivity to OMI VIP..."
checkomibbc=$(/opt/OV/bin/bbcutil -ping omi-bbc.tools.sgns.net |grep -c "status=eServiceOK")
if [[ $checkomibbc == 0 ]]; then
echo "ERROR::OMI BBC status is ERROR" && exit 4 
else echo "INFO::OMI BBC status is OK!"
fi
/opt/OV/bin/bbcutil -ping omi-bbc.tools.sgns.net

echo
echo "INFO::Checking OMI agent version"
/opt/OV/bin/opcagt -list_all_versions
echo
echo Checking OVCONF...
/opt/OV/bin/ovconfget |grep "OPC_IP_ADDRESS"
/opt/OV/bin/ovconfget |grep "OPC_NODENAME"
/opt/OV/bin/ovconfget |grep "CLIENT_BIND_ADDR"
/opt/OV/bin/ovconfget |grep "SERVER_BIND_ADDR"
/opt/OV/bin/ovconfget |grep "LOCAL_NODE_NAME"
/opt/OV/bin/ovconfget |grep "SocketPoll"
echo
echo "INFO::Checking Agent Certs..."
cert=$(/opt/OV/bin/ovcert -status |grep -c "Status: Certificate is installed.")
if  [[ $cert == 0 ]]; then
echo "ERROR::No Certs Installed - ERROR - Confirm OMI.LOCAL DNS & OVCONFGET"  && exit 5
else echo "INFO::Certs Installed"
fi
echo
/opt/OV/bin/ovcert -list
exit 0