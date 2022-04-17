#!/bin/bash
# Configuration command and get information for Dell


function ConfigurationiDracDell(){
# Creat a iDrac user and set user's privilege, set Redundancy and Hotspare for Dell 

	TempSysInfo=$(mktemp)	# Create a temporary file

	DNSRacName=$(echo $iDracHostname | awk -F"." '{print $1}') # Get DNS Rac name

# Verify Server's location to get best NTP server IP
	ServerArea=$(echo $iDracHostname | awk -F"-" '{print $1}')
	if [[ $ServerArea == 'pek2' ]];then
		NTPServer1=10.117.0.1
		NTPServer2=10.110.160.1
	elif [[ $ServerArea == 'sha1' ]];then
		NTPServer1=10.110.160.1
		NTPServer2=10.117.0.1
	else
		NTPServer1=10.117.0.1
		NTPServer2=10.111.0.1
	fi

# Get iDrac User and use default username if it's null
# Get iDrac Password and use default password if it's null
iDracUserGet=$(cat Hostname-List | grep $iDracHostnameInfo | awk '{print $2}')
iDracPasswordGet=$(cat Hostname-List | grep $iDracHostnameInfo | awk '{print $3}')
iDracPassword=${iDracPasswordGet:-'calvin'}
iDracUser=${iDracUserGet:-'root'}

NewAccount=$(cat Hostname-List | grep NewAccount | awk -F= '{print $2}')
NewAccountPassword=$(cat Hostname-List | grep NewAccountPassword | awk -F= '{print $2}')

# The following command is for setting that will be executed in the iDrac
# The RACADM "System.Power" group will be deprecated in a future release of iDRAC firmware. The group attributes will be migrated to "System.ServerPwr".
iDracRacadmDellSet="
racadm set idrac.users.3.username $NewAccount
racadm set idrac.users.3.password $NewAccountPassword
racadm set idrac.users.3.enable 1
racadm set idrac.users.3.privilege 0x1ff
racadm set idrac.users.3.IpmiLanPrivilege 4
racadm set idrac.users.3.IpmiSerialPrivilege 4
racadm set idrac.users.3.SolEnable 1
racadm set System.ServerPwr.PSRedPolicy 0
racadm set System.Power.Hotspare.Enable 1
racadm set iDRAC.Time.Timezone Asia/Shanghai
racadm set iDRAC.NTPConfigGroup.NTPEnable 1
racadm set iDRAC.NTPConfigGroup.NTP1 $NTPServer1
racadm set iDRAC.NTPConfigGroup.NTP2 $NTPServer2
racadm set iDRAC.Nic.DNSRacName $DNSRacName
racadm set iDRAC.Nic.DNSDomainName eng.vmware.com
"

# The following command is for getting Serial Number from the iDrac
iDracRacadmDellGet="
racadm getsysinfo -s
"

# Execute command in the iDrac through ssh
	iDracRacadm=$iDracRacadmDellSet
	sshpass -p $iDracPassword ssh -o StrictHostKeyChecking=no $iDracUser@$iDracHostname > $TempSysInfo 2>&1 << Command
$iDracRacadmDellSet
$iDracRacadmDellGet
Command
	SSHableVerify=$?
}

function ResultVerify(){
# Verify the result of execute command
	DetailsInfo=''
	ResultFailureInfo=''

	for RacadmCommand in $(echo "$iDracRacadmDellSet" | awk '{print $3}')
	do
		# Verify SSH
		if [[ $SSHableVerify != '0' ]];then
			DetailInfo='SSHable verification failed'
			ResultInfo="$(printf "\033[1;31m%-10s\033[0m" "Failure")"
			continue
		else
			ResultFailureInfo=''
		fi
		
		# Verify Execute command result	
		RacadmResult=$(cat $TempSysInfo | grep -A 2 $RacadmCommand | grep 'Object value modified successfully')
		if [[ $RacadmResult != 'Object value modified successfully' ]];then
			ResultFailureInfo="$ResultFailureInfo$RacadmCommand; "
		fi

		if [[ $ResultFailureInfo != '' ]];then
			DetailInfo=$ResultFailureInfo
			ResultInfo="$(printf "\033[1;33m%-10s\033[0m" "Done")"
		else
			DetailInfo="Done successfully"
			ResultInfo="$(printf "\033[1;32m%-10s\033[0m" "Done")"
		fi

		# Get Serial Number info
		SerialNumberInfo=$(cat $TempSysInfo | grep "Service \Tag" | awk -F= '{print $2}' | sed 's/^[\ ]//g')

	done

}

