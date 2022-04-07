#!/bin/bash

function Configuration(){
# Get ILO Hostname from filr Hostname_iDrac_List
	echo 'Configuration for iDrac is in progress.......'
	sed -n '10,999p' Hostname_iDrac_List | while read HostnameiDracLine
	do
		export HostnameiDrac=$HostnameiDracLine-ilo.eng.vmware.com
		
		HostnameDNSTest
		if [[ $HostnameDNSResult != 'Yes' ]];then
			break
		fi
		HostnamePingTest
		if [[ $HostnamePingResult == 'No' ]];then
			break
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
		iDracIP='DNS failed'
	else
		HostnameDNSResult='None'
		iDracIP='DNS failed '
	fi	
}

function HostnamePingTest(){
# To test pingable for iDrac Hostname
	HostnamePingTest=$(ping -w 1 $HostnameiDrac | grep loss | awk '{print $6}')
	if [[ $HostnamePingTest == '0%'  ]];then
		HostnamePingResult='Yes'
		iDracIP=$HostnameDNSTest_3
	else
#		echo -e "\033[31m Yes \033[0m"	-Echo colored font
		HostnamePingResult='No'
		iDracIP='Ping failed'
	fi
}

function AddiDracUserDell(){
# Add user vmware in iDrac, and set privileges. - Just for Dell 
	sudo sshpass -p calvin ssh -o StrictHostKeyChecking=no root@$HostnameiDrac > /dev/null 2>&1 << iDrac_racadm
	#Adduser, number 3 is unique user index
	racadm set idrac.users.3.username vmware

	#Set password
	racadm set idrac.users.3.password VMware1!

	#Enable user
	racadm set idrac.users.3.enable 1

	#set user privileges to Administrator
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
		iDracUserAccountVerify='Successfully'
	else
		iDracUserAccountVerify='Failed'
	fi

}

function Output(){
        printf "%-8s %17s %17s %10s \n" +---- ----+---- ----+---- ----+
        printf "%-20s %-17s %-20s \n" "| "$HostnameiDracLine "| "$iDracIP "| "$iDracUserAccountVerify
}

Configuration
