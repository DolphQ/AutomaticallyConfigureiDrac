#!/bin/bash

# Input and Output for configuration script for dell

# Create 2 temporary file for the script to use

function Progress(){
        Number=0
        Strip=""
	printf "\n"
	while true
        do
		printf "\033[1;35mConfiguring for $iDracHostnameInfo\033[0m%-6s \r" "$Strip"
                sleep 0.5
                let Number=Number+1
                Strip+="."
		if [[ $Strip == '......' ]];then
			Strip=""
		fi
        done

}

function GetUsernamePassword(){
# Get username and password from user entering
	read -p 'Please enter username you want to add:' iDracUsername
	read -s -p 'Please enter password you want to set:' iDracPassword_1
	read -s -p 'Please enter password again:' iDracPassword_2
	CycleFrequency=0
	until [[ $iDracPassword_1 == $iDracPassword_2 ]]
	do	
		CycleFrequency=$CycleFrequency-1
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

	echo "$(printf "|%-18s" "$iDracHostnameInfo")$(printf "|%-16s" "$iDracIPInfo")$(printf "|%-15s" "$SerialNumberInfo")$(printf "|%-13s" "$iDracUserInfo")$(printf "|%-18s" "$PSUBalanceInfo")$(printf "|%-18s" "$NTPInfo")$(printf "|%-12s" "$DNSRacNameInfo")$(printf "|%-23s|" "$OutcomeInfo")
$(printf "|%-18s" "------------------")$(printf "|%-16s" "----------------")$(printf "|%-15s" "---------------")$(printf "|%-13s" "-------------")$(printf "|%-18s" "------------------")$(printf "|%-18s" "------------------")$(printf "|%-12s" "------------")$(printf "|%-12s|" "------------")" >> ConfigurationResult.txt

}

function OutputType(){
# Output
case $1 in

	Title) 
		echo "$(printf "\033[1;33mThe configuration result as following:\033[0m\n")
$(printf "|%-18s" "------------------")$(printf "|%-16s" "----------------")$(printf "|%-15s" "---------------")$(printf "|%-13s" "-------------")$(printf "|%-18s" "------------------")$(printf "|%-18s" "------------------")$(printf "|%-12s" "------------")$(printf "|%-12s|" "------------")" > ConfigurationResult.txt
		iDracHostnameInfo='iDrac Hostname'
		iDracIPInfo='iDrac IP'
		SerialNumberInfo='Serial Number'
		iDracUserInfo='New Account'
		PSUBalanceInfo='PSU Balance'
		DNSRacNameInfo='DNSRacName'
		NTPInfo='NTP Configuration'
		OutcomeInfo="$(printf "\033[0;37mOutcome\033[0m")"
		Output
		;;

	Success)
		OutcomeInfo="$(printf "\033[1;32mCompleted\033[0m")"
		Output
		;;

	*)
		OutcomeInfo="$(printf "\033[1;31mFailed\033[0m")"
		Output
		;;
	
esac

	iDracHostnameInfo=''
	iDracIPInfo=''
	SerialNumberInfo=''
	iDracUserInfo=''
	PSUBalanceInfo=''
	OutcomInfo=''
	DNSRacNameInfo=''
	NTPInfo=''
}

