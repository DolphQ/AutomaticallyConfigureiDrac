#!/bin/bash
# Command of each server module

function ConfigurationiDracDell(){
# Creat a iDrac user and set user's privilege, set Redundancy and Hotspare for Dell 
#The RACADM "System.Power" group will be deprecated in a future release of iDRAC firmware. The group attributes will be migrated to "System.ServerPwr".
	DNSiDracName=$(echo $iDracHostname | awk -F"." '{print $1}')
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
	sudo sshpass -p calvin ssh -o StrictHostKeyChecking=no root@$iDracHostname > /dev/null 2>&1 << iDrac_racadm
	racadm set idrac.users.3.username vmware
	racadm set idrac.users.3.password VMware1!
	racadm set idrac.users.3.enable 1
	racadm set idrac.users.3.privilege 0x1ff
	racadm set System.ServerPwr.PSRedPolicy 0
	racadm set System.Power.Hotspare.Enable 1
	racadm set iDRAC.Time.Timezone Asia/Shanghai
	racadm set iDRAC.NTPConfigGroup.NTPEnable 1
	racadm set iDRAC.NTPConfigGroup.NTP1 $NTPServer1
	racadm set iDRAC.NTPConfigGroup.NTP2 $NTPServer2
	"
iDrac_racadm
}
