#!/bin/bash

# iDrac_Configuration: For iDrac/ILO Automation Configuration

# This script can be:
# 1. Add user for iDrac/iLO and set privilege
# 2. Set PSU Redundancy and Hot Spare
# 3. Get Serial Number and Mac address from iDrac
# 4. Set Time Zone and NTP servers
# 5. Set DNS iDrac Name and Static DNS Domain Name

# Add source script from other files
source ./Configuration_InputOutput.sh
source ./Package_Verify.sh
source ./Configuration_iDracDell.sh


function MainConfiguration(){
# Get ILO Hostname from filr Hostname_iDrac_List
	
	ControlNumber=1		# For Control the number processes

	PackageVerify sshpass	# Verify sshpass package

	OutputType Title	# Output the header of table

	Progress

	for iDracHostnameInfo in $(sed -n '10,999p' Hostname_List);
	do
		iDracHostname=$iDracHostnameInfo-ilo.eng.vmware.com
		{
			HostnameDNSTest		# Verify Hostname
			if [[ $HostnameDNSResult != 'Yes' ]];then
				OutputType Failure
				continue
			fi
			HostnamePingTest	# Verify Pingable
			if [[ $HostnamePingResult != 'Yes' ]];then
				OutputType Failure
				continue
			fi	

			ConfigurationiDracDell	# Configring for iDrac
			ResultVerify		# Verify result
			OutputType Done		# Output after done
		}&

# The maximum of processes is 10
		ControlNumber=$[$ControlNumber+1]
		while [ $ControlNumber -eq 10 ];do
			wait
			ControlNumber=1
		done
	done
	wait

	cat ConfigurationResult.txt
	rm ConfigurationResult.txt
	exit
}

function HostnameDNSTest(){
# To test resolving hostname
	HostnameDNSTest_1=$(host $iDracHostname | grep $iDracHostname | awk '{print $2}')
	HostnameDNSTest_2=$(host $iDracHostname | grep $iDracHostname | awk '{print $3}')
	HostnameDNSTest_3=$(host $iDracHostname | grep $iDracHostname | awk '{print $4}')
	if [[ $HostnameDNSTest_1 == 'has' && $HostnameDNSTest_2 == 'address' ]];then
		HostnameDNSResult='Yes'
		iDracIPInfo=$HostnameDNSTest_3
	elif [[ $HostnameDNSTest_2 == 'not' && $HostnameDNSTest_3 == 'found:' ]];then
		HostnameDNSResult='No'
		DetailInfo='DNS verification is failed'
	else
		DetailInfo='DNS verification is failed'
	fi	
}

function HostnamePingTest(){
# To test pingable for iDrac Hostname
	HostnamePingTest=$(ping -w 1 $iDracIPInfo | grep loss | awk '{print $6}')
	if [[ $HostnamePingTest == '0%'  ]];then
		HostnamePingResult='Yes'
	else
		HostnamePingResult='No'
		DetailInfo='Pingable verification is failed'
	fi
}

MainConfiguration
