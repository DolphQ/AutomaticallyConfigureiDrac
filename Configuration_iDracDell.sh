#!/bin/bash
# Configuration command and get information for Dell

function ConfigurationiDracDell(){
# Creat a iDrac user and set user's privilege, set Redundancy and Hotspare for Dell 
#The RACADM "System.Power" group will be deprecated in a future release of iDRAC firmware. The group attributes will be migrated to "System.ServerPwr".

	DNSRacName=$(echo $iDracHostname | awk -F"." '{print $1}')
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
	sudo sshpass -p calvin ssh -o StrictHostKeyChecking=no root@$iDracHostname > iDracSysInfomation 2>&1 << iDracConfiguratoin
racadm set idrac.users.3.username vmware
racadm set idrac.users.3.password VMware1!
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
iDracConfiguratoin
}

function ConfigurationVerify(){
	return
}

function GetInfoDell(){
# Get server's info from Dell iDrac

	iDracSysInfomation=$(mktemp) 	# Create a temporary file for the script to use

	sudo sshpass -p VMware1! ssh -o StrictHostKeyChecking=no vmware@$iDracHostname > $iDracSysInfomation 2>&1 <<iDracGetInfo
racadm getsysinfo -s4
racadm get System.Power
racadm get idrac.users.3
racadm get iDrac.NTPConfigGroup
racadm get iDRAC.Nic.DNSRacName
racadm get iDRAC.Time.Timezone
iDracGetInfo
	iDracIPInfo=$(cat $iDracSysInfomation | grep "Current\ IP\ Address" | awk -F= '{print $2}' | sed 's/^[\ ]//g')
	SerialNumberInfo=$(cat $iDracSysInfomation | grep "Service \Tag" | awk -F= '{print $2}' | sed 's/^[\ ]//g')
	iDracUserInfo=$(cat $iDracSysInfomation | grep UserName | awk -F= '{print $2}')
	HotSpareInfo=$(cat $iDracSysInfomation | grep -h ^HotSpare.Enable= | awk -F= '{print $2}')
	RedundancyPolicy=$(cat $iDracSysInfomation | grep -h ^RedundancyPolicy= | awk -F= '{print $2}')
	NTPEnable=$(cat $iDracSysInfomation | grep -h ^NTPEnable= | awk -F= '{print $2}')
	NTPServer1=$(cat $iDracSysInfomation | grep -h ^NTP1= | awk -F= '{print $2}')
	DNSRacName=$(cat $iDracSysInfomation | grep -h ^DNSRacName= | awk -F= '{print $2}')
	DNSTimeZone=$(cat $iDracSysInfomation | grep -h ^Timezone= | awk -F= '{print $2}')
	
	# Verify Hostspare and Redundancy configuration
	if [[ $HotSpareInfo == 'Enabled' && $RedundancyPolicy == 'Not Redundant' ]];then
		PSUBalanceInfo='Successfully'
	elif [[ $HotSpareInfo == 'Enabled' && $RedundancyPolicy != 'Not Redundant' ]];then
		PSUBalanceInfo='Redundancy Failed'
	elif [[ $HotSpareInfo != 'Enabled' && $RedundancyPolicy == 'Not Redundant' ]];then
        	PSUBalanceInfo='HotSpare Failed'
	else
		PSUBalanceInfo='All Failed'
	fi

	# Verify NTP configuration
	if [[ $NTPEnable == 'Enabled' && $DNSTimeZone == 'Asia/Shanghai' ]];then
		NTPInfo='Successfully'
	else
		NTPInfo='Failed'
	fi

	# Verify DNSRacName
	if [[ $DNSRacName == "$iDracHostnameInfo-ilo" ]];then
		DNSRacNameInfo='Successfully'
	else
		DNSRacNmaeInfo='Failed'
	fi

}
