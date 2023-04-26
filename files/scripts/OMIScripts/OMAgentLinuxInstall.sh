#!/bin/sh
############################################
#Modified original script for Ansible
############################################
mgmt_ip=$1
snt_code=$2

#mgmt_ip="10.146.62.137"
#snt_code="saot"

chmod -R 777 /tmp/OMI*
[ -z `rpm -qa m4` ]  && yum install -y m4     # prereq
/tmp/OMI/oainstall.sh  -i -a -verbose

omdir=/opt/OV/bin/
if [ ! -d "$omdir" ]; then
echo "ERROR::OM Agent NOT Found!! Install Failed!!" && exit 1
else echo "INFO::Install dir /opt/OV/bin/ is Verified"
echo
fi

#Checking for OMI VIP in /ETC/HOSTS
echo -y |cp -p /etc/hosts /etc/hosts.bak
var0=`hostname | awk -F. '{print $1}'`
domain=".omi.local"
echo "INFO::Checking for OMI-VIP in /etc/hosts"
CHECK1=$(grep -i -c "216.203.5.152 omi-bbc.tools.sgns.net" /etc/hosts)
if [ "$CHECK1" == "0" ]; then
echo -e "# SungardAS OMI VIP Address" >> /etc/hosts  && echo -e "216.203.5.152 omi-bbc.tools.sgns.net" >> /etc/hosts && echo "INFO::OMI-VIP Added Successfully!"
else echo "INFO::OMI-VIP Found, No Update Needed"
fi

#Checking for Management IP
CHECK2=$(ifconfig -a |grep -c "$mgmt_ip")
if [ "$CHECK2" == "0" ]; then
echo "INFO::No Management IP Found!!" && /opt/OV/bin/ovconfchg -ns xpl.net -set LOCAL_NODE_NAME $var0.$snt_code$domain && /opt/OV/bin/ovconfchg -ns xpl.net -set SocketPoll true
else echo "INFO::Management IP Found!!"

/opt/OV/bin/ovconfchg -ns sec.core.auth -clear MANAGER
/opt/OV/bin/ovconfchg -ns sec.core.auth -clear MANAGER_ID
/opt/OV/bin/ovconfchg -ns sec.cm.client -clear CERTIFICATE_SERVER
/opt/OV/bin/ovconfchg -ns sec.core.auth -set MANAGER omi-bbc.tools.sgns.net
/opt/OV/bin/ovconfchg -ns sec.core.auth -set MANAGER_ID 6bb43a90-d44a-428b-8b67-5636070dd029
/opt/OV/bin/ovconfchg -ns sec.cm.client -set CERTIFICATE_SERVER omi-bbc.tools.sgns.net
/opt/OV/bin/ovconfchg -ns eaagt -set OPC_IP_ADDRESS $mgmt_ip
/opt/OV/bin/ovconfchg -ns eaagt -set OPC_NAMESRV_LOCAL_NAME $var0.$snt_code$domain
/opt/OV/bin/ovconfchg -ns eaagt -set OPC_NODENAME $var0.$snt_code$domain
/opt/OV/bin/ovconfchg -ns bbc.cb -set SERVER_BIND_ADDR $mgmt_ip
/opt/OV/bin/ovconfchg -ns bbc.http -set SERVER_BIND_ADDR $mgmt_ip
/opt/OV/bin/ovconfchg -ns bbc.http -set CLIENT_BIND_ADDR $mgmt_ip
/opt/OV/bin/ovconfchg -ns coda.comm -set SERVER_BIND_ADDR $mgmt_ip
/opt/OV/bin/ovconfchg -ns xpl.net -set LOCAL_NODE_NAME $var0.$snt_code$domain
/opt/OV/bin/ovconfchg -ns xpl.net -set SocketPoll true
/opt/OV/bin/ovconfchg -ns eaagt -set OPC_PUB_DIR_NOT_WW true
fi
#Activating OVCONFG and OM Agent
#/opt/OV/bin/ovconfchg
/opt/OV/bin/OpC/install/opcactivate -srv omi-bbc.tools.sgns.net -cert_srv omi-bbc.tools.sgns.net -f
exit 0