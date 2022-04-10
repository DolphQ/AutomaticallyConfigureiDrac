#!/bin/bash

<< Test
HostnameiDrac=sha1-hs1-r1415
iDracIPInfo=$(printf "\033[1;31mDNS_failed\033[0m")
#iDracIPInfo='10.255.255.255'
iDracUserInfo='Successfully'
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
}

function Progress(){
        Number=0
        Strip=""
        Trun=("\\" "|" "/" "-")
        while [ $Number -le 100 ]
        do
                let index=i%4
                printf "\033[1;35mConfigurating\033[0m[%-100s] %d %c\r" "$Strip" "$Number" "${Trun[$index]}"
                sleep 0.35
                let Number=Number+1
                Strip+="#"
        done
echo ""
}

function Output(){
case $1 in

	Title)
echo 'Configuration for iDrac is in progress.......
'
printf "
\033[1;33mThe configuration result was saved in Configuration_Result.txt and as follows:\033[0m\n" > Configuration_Result.txt
echo "+------------------+------------------+------------------+------------------+------------------+------------------+
$(printf "|%-18s" 'iDrac Hostname')$(printf "|%-18s" 'iDrac IP')$(printf "|%-18s" 'Serial Number')$(printf "|%-18s" 'vmware account')$(printf "|%-18s" 'PSU Balance')$(printf "|%-18s|" 'Outcome')" >> Configuration_Result.txt
;;

	DNSFailed)
echo "+------------------+------------------+------------------+------------------+------------------+------------------+
$(printf "|%-18s" "$iDracHostnameInfo")$(printf "|%-18s" "$iDracIPInfo")$(printf "|%-18s" "$SerialNumberInfo")$(printf "|%-18s" "$iDracUserInfo")$(printf "|%-18s" "$PSUBalance")$(printf "|\033[1;31m%-18s\033[0m|" 'Failed')" >> Configuration_Result.txt
;;

	PingFailed)
echo "+------------------+------------------+------------------+------------------+------------------+------------------+
$(printf "|%-18s" "$iDracHostnameInfo")$(printf "|%-18s" "$iDracIPInfo")$(printf "|%-18s" "$SerialNumberInfo")$(printf "|%-18s" "$iDracUserInfo")$(printf "|%-18s" "$PSUBalance")$(printf "|\033[1;31m%-18s\033[0m|" 'Failed')" >> Configuration_Result.txt
;;

	Success)
echo "+------------------+------------------+------------------+------------------+------------------+------------------+
$(printf "|%-18s" "$iDracHostnameInfo")$(printf "|%-18s" "$iDracIPInfo")$(printf "|%-18s" "$SerialNumberInfo")$(printf "|%-18s" "$iDracUserInfo")$(printf "|%-18s" "$PSUBalance")$(printf "|\033[1;32m%-18s\033[0m|" 'Completed')" >> Configuration_Result.txt
;;

	Tail)
echo "+------------------+------------------+------------------+------------------+------------------+------------------+" >> Configuration_Result.txt
;;

esac

}
