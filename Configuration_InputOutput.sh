#!/bin/bash

#<< Test
HostnameiDrac=sha1-hs1-r1415
iDracIP=$(printf "\033[1;31mDNS_failed\033[0m")
#iDracIP='10.255.255.255'
iDracUserAccountVerify='Successfully'
#Test

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
}


function Output(){
case $1 in

	Title)
echo "+------------------+------------------+------------------+------------------+------------------+
$(printf "|%-18s" 'iDrac Hostname')$(printf "|%-18s" 'iDrac IP')$(printf "|%-18s" 'Serial Number')$(printf "|%-18s" 'vmware account')$(printf "|%-18s" 'PSU Balance')"
;;

	DNSFailed)
echo "+------------------+------------------+------------------+------------------+------------------+
$(printf "|%-18s" $HostnameiDracLine)$(printf "|%-29s" $iDracIP)$(printf "|%-18s" $SerialNumber)$(printf "|%-29s" $iDracUserAccountVerify)$(printf "|%-18s" $PSUBalance)"
;;

	PingFailed)
echo "+------------------+------------------+------------------+------------------+------------------+
$(printf "|%-18s" $HostnameiDracLine)$(printf "|%-30s" $iDracIP)$(printf "|%-18s" $SerialNumber)$(printf "|%-18s" $iDracUserAccountVerify)$(printf "|%-18s" $PSUBalance)"
;;

	Success)
echo "+------------------+------------------+------------------+------------------+------------------+
$(printf "|%-18s" $HostnameiDracLine)$(printf "|%-18s" $iDracIP)$(printf "|%-18s" $SerialNumber)$(printf "|%-29s" $iDracUserAccountVerify)$(printf "|%-18s" $PSUBalance)"
;;

	Tail)
echo "+------------------+------------------+------------------+------------------+------------------+"
;;

esac

}
