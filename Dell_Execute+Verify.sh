#!/bin/bash
# Configuration command and get information for Dell


function ConfigurationiDracDell(){
# Creat a iDrac user and set user's privilege, set Redundancy and Hotspare for Dell 

	TempSysInfo=$(mktemp)	# Create a temporary file

	DNSRacName=$(echo $iDracHostname | awk -F"." '{print $1}') # Get DNS Rac name

# Get iDrac User and use default username if it's null
# Get iDrac Password and use default password if it's null
	iDracUserGet=$(cat Hostname+ConfigField | grep $iDracHostnameInfo | awk '{print $2}')
	iDracPasswordGet=$(cat Hostname+ConfigField | grep $iDracHostnameInfo | awk '{print $3}')
	iDracPassword=${iDracPasswordGet:-'calvin'}
	iDracUser=${iDracUserGet:-'root'}
	
	NewAccount=$(cat Hostname+ConfigField | grep "NewAccount=" | awk -F= '{print $2}')
	NewAccountPassword=$(cat Hostname+ConfigField | grep NewAccountPassword | awk -F= '{print $2}')
	TimeZone=$(cat Hostname+ConfigField | grep TimeZone | awk -F= '{print $2}')
	DNSDomainName=$(cat Hostname+ConfigField | grep DNSDomainName | awk -F= '{print $2}')
	NTPServer1=$(cat Hostname+ConfigField | grep NTPServer1 | awk -F= '{print $2}')
	NTPServer2=$(cat Hostname+ConfigField | grep NTPServer2 | awk -F= '{print $2}')

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
racadm set iDRAC.Time.Timezone $TimeZone
racadm set iDRAC.NTPConfigGroup.NTPEnable 1
racadm set iDRAC.NTPConfigGroup.NTP1 $NTPServer1
racadm set iDRAC.NTPConfigGroup.NTP2 $NTPServer2
racadm set iDRAC.Nic.DNSRacName $DNSRacName
racadm set iDRAC.Nic.DNSDomainName $DNSDomainName
"

# The following command is for getting Serial Number from the iDrac
iDracRacadmDellGet="
racadm getsysinfo -s4
racadm get System.Power
racadm get idrac.users.3
racadm get iDrac.NTPConfigGroup
racadm get iDRAC.Nic.DNSRacName
racadm get iDRAC.Time.Timezone
"

# Execute command in the iDrac through ssh
	sshpass -p $iDracPassword ssh -o StrictHostKeyChecking=no $iDracUser@$iDracHostname > $TempSysInfo 2>&1 << Command
$iDracRacadmDellSet
$iDracRacadmDellGet
Command
	SSHableVerify=$?
}

function ResultVerify(){
# Verify the result
	SerialNumberInfo=$(cat $TempSysInfo | grep "Service \Tag" | awk -F= '{print $2}' | sed 's/^[\ ]//g')
	iDracUserInfo=$(cat $TempSysInfo | grep UserName | awk -F= '{print $2}')
	HotSpareInfo=$(cat $TempSysInfo | grep -h ^HotSpare.Enable= | awk -F= '{print $2}')
	RedundancyPolicy=$(cat $TempSysInfo | grep -h ^RedundancyPolicy= | awk -F= '{print $2}')
	NTPEnable=$(cat $TempSysInfo | grep -h ^NTPEnable= | awk -F= '{print $2}')
	NTPServer1=$(cat $TempSysInfo | grep -h ^NTP1= | awk -F= '{print $2}')
	NTPServer2=$(cat $TempSysInfo | grep -h ^NTP2= | awk -F= '{print $2}')
	DNSRacName=$(cat $TempSysInfo | grep -h ^DNSRacName= | awk -F= '{print $2}')
	NTPTimeZone=$(cat $TempSysInfo | grep -h ^Timezone= | awk -F= '{print $2}')	

# Verify the reslut of execute command
	for RacadmCommand in $(echo "$iDracRacadmDellSet" | awk '{print $3}')
	do
	ResultFailureInfo=''

	if [[ $SSHableVerify != '0' ]];then
		OutcomeInfo="$(printf "\033[1;31m%-12s\033[0m" "Failure")"
		continue
	else
		ResultFailureInfo=''
	fi

	RacadmResult=$(cat $TempSysInfo | grep -A 2 $RacadmCommand | grep 'Object value modified successfully')
		if [[ $RacadmResult != 'Object value modified successfully' ]];then
			ResultFailureInfo="$ResultFailureInfo$RacadmCommand;"
		fi

		if [[ $ResultFailureInfo != '' ]];then
			OutcomeInfo="$(printf "\033[1;33m%-12s\033[0m" "Done")"
		else
			OutcomeInfo="$(printf "\033[1;32m%-12s\033[0m" "Done")"
		fi
	done
}

