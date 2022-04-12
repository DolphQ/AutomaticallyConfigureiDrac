#!/bin/bash

# iDrac_Configuration: For iDrac/ILO Automation Configuration

# This script can be:
# 1. Add user for iDrac/iLO
# 2. Set PSU Redundancy and Hot Spare
# 3. Get Serial Number and Mac address from iDrac

# Add source from other scripts
source ./Configuration_InputOutput.sh
source ./Package_Verify.sh
source ./Configuration_Command.sh



function Configuration(){
# Get ILO Hostname from filr Hostname_iDrac_List
	
# $ControlNumber for control number of processes
	ControlNumber=1

	OutputType Title
	for iDracHostnameInfo in $(sed -n '10,999p' Hostname_List);
	do
		iDracHostname=$iDracHostnameInfo-ilo.eng.vmware.com
		{
			HostnameDNSTest
			if [[ $HostnameDNSResult != 'Yes' ]];then
				OutputType DNSFailed
				continue
			fi
			HostnamePingTest
			if [[ $HostnamePingResult == 'No' ]];then
				OutputType PingFailed
				continue
			fi
			ConfigurationiDracDell
			GetInfoDell
			OutputType Success
		}&

# The maximum of processes is 10
		while [ $ControlNumber -eq 10 ];do
			wait
			ControlNumber=1
		done
	done&
	wait
	exit 1

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

PackageVerify sshpass

Configuration
Progress
cat ConfigurationResult.txt
