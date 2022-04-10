#!/bin/bash

# iDrac_Configuration: For iDrac/ILO Automation Configuration

# This script can be:
# 1. Add user for iDrac/iLO
# 2. Set PSU Redundancy and Hot Spare
# 3. Get Serial Number and Mac address from iDrac

source ./Configuration_InputOutput.sh


function Configuration(){
# Get ILO Hostname from filr Hostname_iDrac_List
	
# $ControlNumber for control number of processes
	ControlNumber=1

	Output Title
	Progress&
	for iDracHostnameInfo in $(sed -n '10,999p' Hostname_iDrac_List);
	do
		export iDracHostname=$iDracHostnameInfo-ilo.eng.vmware.com
		{
			HostnameDNSTest
			if [[ $HostnameDNSResult != 'Yes' ]];then
				Output DNSFailed
				continue
			fi
			HostnamePingTest
			if [[ $HostnamePingResult == 'No' ]];then
				Output PingFailed
				continue
			fi
			ConfigurationiDracDell
			GetInfoDell
			Output Success
		}&

# The maximum of processes is 10
		while [ $ControlNumber -eq 10 ];do
			wait
			ControlNumber=1
		done
	done
	wait
	Output Tail
	cat $ConfigurationResult
	exit
}

function HostnameDNSTest(){
# To test resolving hostname
	HostnameDNSTest_1=$(host $iDracHostname | grep $iDracHostname | awk '{print $2}')
	HostnameDNSTest_2=$(host $iDracHostname | grep $iDracHostname | awk '{print $3}')
	HostnameDNSTest_3=$(host $iDracHostname | grep $iDracHostname | awk '{print $4}')
	if [[ $HostnameDNSTest_1 == 'has' && $HostnameDNSTest_2 == 'address' ]];then
		HostnameDNSResult='Yes'
	elif [[ $HostnameDNSTest_2 == 'not' && $HostnameDNSTest_3 == 'found:' ]];then
		HostnameDNSResult='No'
		iDracIPInfo='DNS failed'
	else
		HostnameDNSResult='None'
		iDracIPInfo='DNS failed'
	fi	
}

function HostnamePingTest(){
# To test pingable for iDrac Hostname
	HostnamePingTest=$(ping -w 1 $iDracHostname | grep loss | awk '{print $6}')
	if [[ $HostnamePingTest == '0%'  ]];then
		HostnamePingResult='Yes'
	else
		HostnamePingResult='No'
		iDracIPInfo='Ping failed'
	fi
}

function ConfigurationiDracDell(){
# Creat a iDrac user and set user's privilege, set Redundancy and Hotspare for Dell 
#The RACADM "System.Power" group will be deprecated in a future release of iDRAC firmware. The group attributes will be migrated to "System.ServerPwr".
	sudo sshpass -p calvin ssh -o StrictHostKeyChecking=no root@$iDracHostname > /dev/null 2>&1 << iDrac_racadm
	racadm set idrac.users.3.username vmware
	racadm set idrac.users.3.password VMware1!
	racadm set idrac.users.3.enable 1
	racadm set idrac.users.3.privilege 0x1ff
	racadm set System.ServerPwr.PSRedPolicy 0
	racadm set System.Power.Hotspare.Enable 1
	"
iDrac_racadm
}

function GetInfoDell(){
# Get server's info from Dell iDrac
# Create a temporary file for the script to use
	iDracSysInfomation=$(mktemp)

	sudo sshpass -p VMware1! ssh -o StrictHostKeyChecking=no vmware@$iDracHostname > $iDracSysInfomation 2>&1 <<iDrac_racadm
	racadm getsysinfo -s4
	racadm get System.Power
	racadm get idrac.users.3
iDrac_racadm
	iDracIPInfo=$(cat $iDracSysInfomation | grep "Current\ IP\ Address" | awk -F= '{print $2}' | sed 's/^[\ ]//g')
	SerialNumberInfo=$(cat $iDracSysInfomation | grep "Service\ Tag" | awk -F= '{print $2}' | sed 's/^[\ ]//g')
	iDracUserInfo=$(cat $iDracSysInfomation | grep UserName | awk -F= '{print $2}')
	HotSpareInfo=$(cat $iDracSysInfomation | grep HotSpare.Enable | awk -F= '{print $2}')
	RedundancyPolicy=$(cat $iDracSysInfomation | grep RedundancyPolicy | awk -F= '{print $2}')
	if [[ $HotSpareInfo == 'Enabled' && $RedundancyPolicy == 'Not Redundant' ]];then
		PSUBalanceInfo='Successfully'
	elif [[ $HotSpareInfo == 'Enabled' && $RedundancyPolicy != 'Not Redundant' ]];then
		PSUBalanceInfo='Redundancy Failed'
	elif [[ $HotSpareInfo != 'Enabled' && $RedundancyPolicy == 'Not Redundant' ]];then
        	PSUBalanceInfo='HotSpare Failed'
	else
		PSUBalanceInfo='All Failed'
	fi
}
#iDracHostname='sha1-hs1-r2215-ilo.eng.vmware.com'
#HostnameDNSTest
#echo $iDracIPInfo
Configuration
