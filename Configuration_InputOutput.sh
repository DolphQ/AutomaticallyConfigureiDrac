#!/bin/bash

<< Test
HostnameiDrac=sha1-hs1-r1415
iDracIP='10.255.255.255'
iDracUserAccountVerify='Successfully'
Test

function GetUsernamePassword(){
# Get username and password from user entering
	read -p 'Please enter username you want to add:' iDracUsername
	read -s -p 'Please enter password you want to set:' iDracPassword_1
	read -s -p 'Please enter password again:' iDracPassword_2
	CycleFrequency=0
	until [[ $iDracPassword_1 == $iDracPassword_2 ]]
	do	
		CycleFrequency=$CycleFrequency+1
		echo 'The passwords you entered twice do not match, please try again!'
		read -s -p 'Please enter password you want wo set:' iDracPassword_1
		read -s -p 'Please enter password again:' iDracPassword_2
		if [[ $CycleFrequency -eq 3 ]];then
			echo 'Too many failures, please check and try again'
			exit
		fi
	done      	
	return
}

function Output(){
	printf "%-8s %17s %17s %10s \n" +---- ----+---- ----+---- ----+
	printf "%-20s %-17s %-20s \n" "| "$HostnameiDrac "| "$iDracIP "| "$iDracUserAccountVerify
	printf "%-8s %17s %17s %10s \n" +---- ----+---- ----+---- ----+
}

