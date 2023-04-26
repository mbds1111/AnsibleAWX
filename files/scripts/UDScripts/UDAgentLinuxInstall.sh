#!/bin/sh
############################################
#Modified original script for Ansible
############################################
# UDAgent install wrapper script
# Called from HPSA by Software Policy
# Author : Sumitro Chowdhury
# First Draft : 5/10/2017
# Change LOG: 6/19/2007 : Removed ping dependency for failure. 
############################################
######################################
# Return code by the wrapper script
#   0: SUCCESS
#  16: call home IP not available
#  17: cannot ping call home IP
#  18: Required files are running
#  19: /tmp/udagent directory is missing.
#  20: Python Opsware API access is not installed. (OPSW Agent Tools missing ).
#  21: Unsupported vendor 
#  22: Agent is not running
#  23: Cannot set route to the UDProbeIP 
#  24: Route to the UDProbeIP already set
#   0: Already installed
######################################
##############################################################################################
#
# Return error codes from the UDAgent installer script.
#  1: general error
#  2: wrong parameter
#  3: not root user/permission denied
#  4: file/directory creation error
#  5: wrong platform
#  6: system package installer not found
#  7: directory missing
#  8: file missing
#  9: file not executable
# 10: link startup script error
# 11: startup script error
# 12: agent installed already
# 13: system package installer error
# 14: run agent with non-root user error
# 15: The agent process is running, DDMi agent may be installed
##############################################################################################

##############################################################################################
#
# Variable's default settings
#
##############################################################################################

#Read UDProbeI
CALLHOMEIP=$1
#CALLHOMEIP="69.164.113.145"

# Default variable settings.
INSTALLER_DIR=/opt/HP/udagent
#INSTALLER_DIR=/home/sas-smc/UDAgent
OS_SYSTEM=`uname`
OS_ARCH="unknown"

####################################
# Functions
####################################

Select_Installer_File_Group()
{
  case $VENDOR in 
     # "IBM")
        # INSTALL_FILE=hp-ud-agent-aix-ppc.bff
        # GROUP=system
        # ;;
     # "HP")
        # MAC=`/opt/opsware/agent_tools/get_info.sh|grep osFlavor|awk -F: '{print $2}'`
        # if echo $MAC|grep -i risc
        # then
         # INSTALL_FILE=hp-ud-agent-hpux-hppa.depot
        # else
         # INSTALL_FILE=hp-ud-agent-hpux-ia64.depot
        # fi
        # GROUP=sys
        # ;;
     # "Sun")
         # MAC=`uname -m`
         # if echo $MAC|grep -i i86
         # then
           # INSTALL_FILE=hp-ud-agent-solaris-x86.i86pc
         # else
           # INSTALL_FILE=hp-ud-agent-solaris-sparc.sparc
         # fi
         # GROUP=root
         # ;; 
      "RedHat")
         MAC=`uname -m`
         if echo $MAC|grep -i x86_64
         then
           INSTALL_FILE=hp-ud-agent-linux-x64.rpm
         else
           INSTALL_FILE=hp-ud-agent-linux-x86.rpm
         fi
         GROUP=root
         ;;
       *)
         echo "ERROR::Unexpected error!! Could not read OS architecture"
         exit 1;
  esac
}

GetOsVendor()
{
    case "`/bin/uname -s`" in
        # "AIX")
            # echo "IBM"
            # ;;
        # "HP-UX")
            # echo "HP"
            # ;;
        "Linux")
            if [ -f /etc/SuSE-release ]; then
                echo "SuSE"
            elif [ -f /etc/debian_version ]; then
                echo "Debian"
            elif [ -f /etc/redhat-release ]; then
                 echo "RedHat"
            elif [ -f /etc/turbolinux-release ]; then
                 echo "TurboLinux"
            elif [ -d /etc/vmware ]; then
                 echo "VMware"
            else
                echo "INFO::Unknow OS Vendor@VENDOR_UNKNOWN@"
                return 1
            fi
            ;;
        # "OSF1")
            # echo "Compaq"
            # ;;
        # "SunOS")
            # echo "Sun"
            # ;;
        *)
            /bin/uname -s
            return 1
            ;;
    esac
    return 0
}

# getSetGW()
# {
  # OPSWGW=`grep opswgw.gw_list /etc/opt/opsware/agent/opswgw.args|awk '{print $2}'|awk -F: '{print $1}'|awk -F. '{print $1"."$2"."$3}'`
  # if [ -z "$OPSWGW" ]
  # then
    # echo "ERROR: OPSWARE Gateway not found. Cannot set route to UDProbe IP, please fix manually."
    # exit 23
  # fi      
  # PROBENET=`echo $CALLHOMEIP|awk -F. '{print $1"."$2"."$3".0"}'`
  # PROBE3OCT=`echo $CALLHOMEIP|awk -F. '{print $1"."$2"."$3}'`
  # MGMTGW=`netstat -rn|grep "$OPSWGW"|awk '{print $2}'|sort -u`
  # if [ -z "$MGMTGW" ]
  # then
     # echo "ERROR: Sungard Mgmt Gateway not set inside any static route. Using default route, please fix manually if needed."
#     exit from function 
     # return 0
  # fi
  # netstat -rn|grep $PROBE3OCT >/dev/null
  # if [ $? = 0 ]
  # then
     # echo "INFO: Route already set. Fix Probe communication manually. Proceeding with agent install anyways."
     # return 0
  # fi
  # case $VENDOR in 
     # "IBM")
        # chdev -l inet0 -a route="net,-hopcount,0,-netmask,255.255.255.0,,,,,,-static,$PROBENET,$MGMTGW"
        # if [ $? != 0 ]
        # then
           # echo "Cannot set route to UDProbe IP, please fix manually."
           # exit 23
        # fi
        # ;;
     # "HP")
        # F=/etc/rc.config.d/netconf
        # X=0
        # Y=true
        # while [ $Y = "true" ]
        # do
          # cat $F|grep "ROUTE_COUNT\\[$X\]" >/dev/null
          # if [ $? != 0 ]
          # then
           # echo Adding route count $X ...
           # Y=false
          # else
           # X=`expr $X + 1`
          # fi
        # done
        # /usr/bin/cp $F $F.PriorUDAgent.$X
        # echo >> $F
        # echo ROUTE_DESTINATION[$X]=\"net $PROBENET\" >> $F
        # echo ROUTE_MASK[$X]=\"255.255.255.0\" >> $F
        # echo ROUTE_GATEWAY[$X]=\"$MGMTGW\" >> $F
        # echo ROUTE_COUNT[$X]=\"1\" >> $F
        # echo ROUTE_ARGS[$X]=\"\" >> $F
        # /sbin/init.d/net start 
        # if [ $? != 0 ]
        # then
           # echo "Cannot set route to UDProbe IP, please fix manually."
           # exit 23
        # fi
        # ;;
     # "Sun")
	# if [ -f  /etc/inet/static_routes-DefaultFixed ]
	# then
          # cp /etc/inet/static_routes-DefaultFixed /etc/inet/static_routes-DefaultFixed.`date +%d%h%Y-%H:%M`
        # fi
        # /usr/sbin/route -p add -net $PROBENET/24 -gateway $MGMTGW
        # if [ $? != 0 ]
        # then
           # echo "Cannot set route to UDProbe IP, please fix manually."
           # exit 23
        # fi
        # ;; 
      # "RedHat")
	# INTERFACE=`netstat -rn| grep $MGMTGW | awk '{print $8}'|sort -u`
 	# if [ -f /etc/sysconfig/network-scripts/route-$INTERFACE ]
        # then
           # cp /etc/sysconfig/network-scripts/route-$INTERFACE /etc/sysconfig/network-scripts/route-$INTERFACE.`date +%d%h%Y-%H:%M`
	# fi
	# echo "$PROBENET/24 via $MGMTGW dev $INTERFACE" >> /etc/sysconfig/network-scripts/route-$INTERFACE
	# /sbin/ip route add $PROBENET/24 via $MGMTGW dev $INTERFACE
        # if [ $? != 0 ]
        # then
           # echo "Cannot set route to UDProbe IP, please fix manually."
           # exit 23
        # fi
        # ;;
       # *)
         # echo "Unexpected error"
         # exit 1;
  # esac
# }

pingCheck()
{
  
#if [ $VENDOR = "HP" ]
#  then
#    ping $CALLHOMEIP -n1 -m2
#    PING_STATUS=$?
#  else
    ping -c1 $CALLHOMEIP
    PING_STATUS=$?
  #fi
}

##################################################
# MAIN  
##################################################

if [ ! -d $INSTALLER_DIR ]
then
 echo "ERROR::$INSTALLER_DIR is missing, cannot install."
 exit 19
fi

VENDOR=`GetOsVendor`
#if [ "$VENDOR" != "IBM" ] && [ "$VENDOR" != "HP" ] && [ "$VENDOR" != "RedHat" ] && [ "$VENDOR" != Sun ]
if [ "$VENDOR" != "RedHat" ]
then
 echo "ERROR::Unsupported OS Vendor : $VENDOR"
 exit 21
fi 

#if [ ! -d /opt/opsware/agent_tools ] || [ ! -f /opt/opsware/agent_tools/get_cust_attr.sh ]
#then
# echo Please install Opsware Agent Tools 
# exit 20
#fi

#if /opt/opsware/agent_tools/get_cust_attr.sh UDProbeIP
#then
#  CALLHOMEIP=`/opt/opsware/agent_tools/get_cust_attr.sh UDProbeIP`
#else
#  echo "Call home IP attribute not set, run flow UD_to_SA->setProbeIPCustomAttribute against this server"
#  exit 16
#fi
Select_Installer_File_Group

if [ ! -f $INSTALLER_DIR/$INSTALL_FILE ] || [ ! -f $INSTALLER_DIR/agentinstall.sh ] || [ ! -f $INSTALLER_DIR/acstrust.cert ] || [ ! -f  $INSTALLER_DIR/agentca.pem ]
then
  echo "EROR::Required installer files or certificates are missing, cannot install"
  exit 18
fi


pingCheck
if [ $PING_STATUS != 0 ]
then
  echo "ERROR::UdProbe IP "$CALLHOMEIP" is not reachable from the target server!!. Fix this manually."
  exit 1
  #getSetGW
fi

if [ -f /etc/init.d/discagent ]
then
  STATUS=`/etc/init.d/discagent status`
  if echo $STATUS|grep -i "is running"
  then
    echo "INFO:: Agent is already installed, exiting."
    exit 0
  fi
fi

#### Call UD agent installer script
cd $INSTALLER_DIR
chmod 755 agentinstall.sh
echo ./agentinstall.sh $INSTALL_FILE --port 2738 --user root --group $GROUP --url0 $CALLHOMEIP --url1 $CALLHOMEIP --url2 $CALLHOMEIP --timeout 86400 --upgrade
./agentinstall.sh $INSTALL_FILE --port 2738 --user root --group $GROUP --url0 $CALLHOMEIP --url1 $CALLHOMEIP --url2 $CALLHOMEIP --timeout 86400 --upgrade
RC_CODE=$?

if [ $RC_CODE != 0 ]
then
 echo "ERROR::Installation unsuccessful, return code is "$RC_CODE""
 exit $RC_CODE
fi

STATUS=`/etc/init.d/discagent status`
if echo $STATUS|grep -i "is running"
then
  echo "INFO::UD Agent is installed successfully."
  exit 0
else 
  ps -ef|grep discagnt|grep -v grep
  if [ $? = 0 ]
  then 
  	echo "INFO::UD Agent is installed successfully."
        exit 0
  else
  	echo "ERROR::Agent is not running"
  	exit 22
  fi
fi

### END ###
