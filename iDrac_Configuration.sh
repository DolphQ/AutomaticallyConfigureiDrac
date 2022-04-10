#!/bin/bash

# iDrac_Configuration: For iDrac/ILO Automation Configuration

# This script can be:
# 1. Add user for iDrac/iLO
# 2. Set PSU Redundancy and Hot Spare
# 3. Get Serial Number and Mac address from iDrac

source ./Configuration_InputOutput.sh

function Configuration(){
# Get ILO Hostname from filr Hostname_iDrac_List
	Output Title
	Progress&
	for iDracHostnameInfo in $(sed -n '10,999p' Hostname_iDrac_List);
	do
		ControlNumber=1
		export iDracHostname=$iDracHostnameInfo-ilo.eng.vmware.com
#		{
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
		AddiDracUserDell
		GetInfoDell
		Output Success
#		} &
		#ControlNumber=$[$ControlNumber+1]
		#if [[ $ControlNumber -eq 10 ]];then
		#	wait
		#	ControlNumber=1
		#fi
	done
	wait
	Output Tail
	cat Configuration_Result.txt
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

function AddiDracUserDell(){
# Add user vmware in iDrac, and set privileges. - Just for Dell 
	sudo sshpass -p calvin ssh -o StrictHostKeyChecking=no root@$iDracHostname > /dev/null 2>&1 << iDrac_racadm
	racadm set idrac.users.3.username vmware
	racadm set idrac.users.3.password VMware1!
	racadm set idrac.users.3.enable 1
	racadm set idrac.users.3.privilege 0x1ff
	"
iDrac_racadm
	return
}

function GetInfoDell(){
# Get server's info from Dell iDrac
	iDracSysInfomation=$(sudo sshpass -p VMware1! ssh -o StrictHostKeyChecking=no vmware@$iDracHostname racadm getsysinfo)
	SerialNumberInfo=$(echo "$iDracSysInfomation" | grep "Service\ Tag" | awk -F= '{print $2}' | sed 's/^[\ ]//g')
	iDracIPInfo=$(echo "$iDracSysInfomation" | head -n 25 | grep "Current\ IP\ Address" | awk -F= '{print $2}' | sed 's/^[\ ]//g')
	iDracUserInfomation=$(sudo sshpass -p calvin ssh -o StrictHostKeyChecking=no root@$iDracHostname racadm get idrac.users.3)
	iDracUserInfo=$(echo "$iDracUserInfomation" | grep UserName | awk -F= '{print $2}')
}
#iDracHostname='sha1-hs1-r2215-ilo.eng.vmware.com'
#HostnameDNSTest
#echo $iDracIPInfo
Configuration
