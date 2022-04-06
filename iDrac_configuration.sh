#!/bin/bash



function Configuration(){
# Get ILO Hostname from filr Hostname_iDrac_List
	sed -n '10,999p' Hostname_iDrac_List | while read HostnameiDracLine
	do
		export HostnameiDrac=$HostnameiDracLine-ilo.eng.vmware.com
# Confiuration for iDrac
		HostnamePingTest
	done
}


function HostnamePingTest(){
# To test pingable for iDrac Hostname
	HostnamePingTest=`ping -w 1 $HostnameiDrac | grep loss | awk '{print \$6}'`
	if [[ $HostnamePingTest == '0%'  ]];then
		HostnamePingResult='Yes'
	else
#		echo -e "\033[31m Yes \033[0m"	-Echo colored font
		HostnamePingResult='No'
	fi
	echo $HostnamePingResult
}


function AddiDracUserDell(){
# Add user vmware in iDrac, and set privileges. - Just for Dell 
	sudo sshpass -p calvin ssh -o StrictHostKeyChecking=no root@$HostnameiDrac.eng.vmware.com > /dev/null 2>&1 << idrac_racadm
	#Adduser, number 2 is unique user index
	racadm set idrac.users.3.username vmware

	#Set password
	racadm set idrac.users.3.password vmware

	#Enable user
	racadm set idrac.users.3.enable 1

	#Verify user
	racadm get idrac.users.3

	#set user privileges to Administrator
	racadm set idrac.users.3.privilege 0x1ff
	exit"
idrac_racadm
	return
}

Configuration
