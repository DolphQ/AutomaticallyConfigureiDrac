#!/bin/bash

# iDrac_Configuration: For iDrac/ILO Automation Configuration

# This script can be:
# 1. Add user for iDrac/iLO
# 2. Set PSU Redundancy and Hot Spare
# 3. Get Serial Number and Mac address from iDrac

function Configuration(){
# Get ILO Hostname from filr Hostname_iDrac_List
	echo 'Configuration for iDrac is in progress.......'
	echo "$(printf "\033[1;34mThe configuration result is as follows:\033[0m")"
	sed -n '10,999p' Hostname_iDrac_List | while read HostnameiDracLine
	do
		export HostnameiDrac=$HostnameiDracLine-ilo.eng.vmware.com
		
		HostnameDNSTest
		if [[ $HostnameDNSResult != 'Yes' ]];then
			iDracUserAccountVerify=$(printf "\033[1;31mFailed\033[0m")
			Output
			continue
		fi
		HostnamePingTest
		if [[ $HostnamePingResult == 'No' ]];then
			Output
			continue
		fi
		AddiDracUserDell
		iDracConfigurationVerify
		Output
	done
}

function HostnameDNSTest(){
# To test resolving hostname
	HostnameDNSTest_1=$(host $HostnameiDrac | grep $HostnameiDrac | awk '{print $2}')
	HostnameDNSTest_2=$(host $HostnameiDrac | grep $HostnameiDrac | awk '{print $3}')
	HostnameDNSTest_3=$(host $HostnameiDrac | grep $HostnameiDrac | awk '{print $4}')
	if [[ $HostnameDNSTest_1 == 'has' && $HostnameDNSTest_2 == 'address' ]];then
		HostnameDNSResult='Yes'
	elif [[ $HostnameDNSTest_2 == 'not' && $HostnameDNSTest_3 == 'found:' ]];then
		HostnameDNSResult='No'
		iDracIP=$(printf "\033[1;31mDNS_failed\033[0m")
	else
		HostnameDNSResult='None'
		iDracIP=$(printf "\033[1;31mDNS_failed\033[0m")
	fi	
}

function HostnamePingTest(){
# To test pingable for iDrac Hostname
	HostnamePingTest=$(ping -w 1 $HostnameiDrac | grep loss | awk '{print $6}')
	if [[ $HostnamePingTest == '0%'  ]];then
		HostnamePingResult='Yes'
		iDracIP=$HostnameDNSTest_3
	else
		HostnamePingResult='No'
		iDracIP=$(printf "\033[1;31mPing_failed\033[0m")
	fi
}

function AddiDracUserDell(){
# Add user vmware in iDrac, and set privileges. - Just for Dell 
	sudo sshpass -p calvin ssh -o StrictHostKeyChecking=no root@$HostnameiDrac > /dev/null 2>&1 << iDrac_racadm
	racadm set idrac.users.3.username vmware
	racadm set idrac.users.3.password VMware1!
	racadm set idrac.users.3.enable 1
	racadm set idrac.users.3.privilege 0x1ff
	exit"
iDrac_racadm
	return
}

function iDracConfigurationVerify(){
# Verify if the configuration is successfully for iDrac
	iDracUserVerifyOutput=$(sudo sshpass -p calvin ssh -o StrictHostKeyChecking=no root@$HostnameiDrac racadm get idrac.users.3)
	iDracUserVerify=$(echo $iDracUserVerifyOutput | awk '{print $12}' | awk -F= '{print $2}')
	iDracUser=$(echo $iDracUserVerifyOutput | awk '{print $22}' | awk -F= '{print $2}')
	if [[ $iDracUserVerify == '0x1ff' && $iDracUser == 'vmware' ]];then
		iDracUserAccountVerify=$(printf "\033[1;32mSuccessfully\033[0m")
	else
		iDracUserAccountVerify=$(printf "\033[1;31mFailed\033[0m")
	fi

}


Configuration
