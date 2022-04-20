#!/bin/bash

# Input and Output for configuration script for dell

# Create 2 temporary file for the script to use

function ProgressBar(){
# Progress bar 
        Strip=""
	while true
        do
		printf "Configuration is in progress %-6s \r" "$Strip"
                sleep 0.5
                Strip+="."
		if [[ $Strip == '......' ]];then
			Strip=""
		fi
        done

}

function Output(){
# Output infomation and table
	case $1 in
		String)
			echo "$(printf "|%-20s" "$iDracHostnameInfo")$(printf "|%-16s" "$iDracIPInfo")$(printf "|%-15s" "$SerialNumberInfo")$(printf "|%-10s" "$ResultInfo")$(printf "|%-40s" "$DetailInfo")" >> ConfigurationResult.txt
			;;
		Table)
			echo "$(printf "|%-20s" "--------------------")$(printf "|%-16s" "----------------")$(printf "|%-15s" "---------------")$(printf "|%-10s" "----------")$(printf "|%-30s" "------------------------------")" >> ConfigurationResult.txt
			;;
	esac
}

function ClearInfo(){
# Clear infomation
	iDracHostnameInfo=''
	iDracIPInfo=''
	SerialNumberInfo=''
	iDracUserInfo=''
	OutcomInfo=''
	DetailInfo=''

}

function OutputType(){
# Output
case $1 in

	Title) 
		printf "\033[1;36mThe configuration result as follows:\033[0m\n" > ConfigurationResult.txt
		iDracHostnameInfo='iDrac Hostname'
		iDracIPInfo='iDrac IP'
		SerialNumberInfo='Serial Number'
		iDracUserInfo='New Account'
		ResultInfo='Result'
		DetailInfo='Details'
		Output Table
		Output String
		Output Table
		ClearInfo
		;;

	Done)
		Output String
		Output Table
		ClearInfo
		;;

	Failure)
		ResultInfo="$(printf "\033[1;31m%-10s\033[0m" "Failure")"
		Output String
		Output Table
		ClearInfo
		;;
	
esac

}

