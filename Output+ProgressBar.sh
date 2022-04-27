#!/bin/bash
#!/user/bin/env python

# Input and Output for configuration script for dell

# Create 2 temporary file for the script to use


function Output(){
# Output infomation and table
	case $1 in
		String)
			echo "$(printf "|%-18s" "$iDracHostnameInfo")$(printf "|%-16s" "$iDracIPInfo")$(printf "|%-15s" "$SerialNumberInfo")$(printf "|%-13s" "$iDracUserInfo")$(printf "|%-18s" "$RedundancyPolicy")$(printf "|%-18s" "$NTPEnable")$(printf "|%-15s" "$NTPTimeZone")$(printf "|%-12s|" "$OutcomeInfo")
$(printf "|%-18s" "------------------")$(printf "|%-16s" "----------------")$(printf "|%-15s" "---------------")$(printf "|%-13s" "-------------")$(printf "|%-18s" "------------------")$(printf "|%-18s" "------------------")$(printf "|%-15s" "---------------")$(printf "|%-12s|" "------------")" >> /home/$Myself/ConfigurationResult.txt
			;;
		Table)
			echo "$(printf "|%-18s" "------------------")$(printf "|%-16s" "----------------")$(printf "|%-15s" "---------------")$(printf "|%-13s" "-------------")$(printf "|%-18s" "------------------")$(printf "|%-18s" "------------------")$(printf "|%-15s" "---------------")$(printf "|%-12s|" "------------")" >> /home/$Myself/ConfigurationResult.txt
			;;
	esac
}

function ClearInfo(){
# Clear infomation

	iDracHostnameInfo=''
	iDracIPInfo=''
	SerialNumberInfo=''
	iDracUserInfo=''
	RedundancyPolicy=''
        HotSpareInfo=''
	OutcomInfo=''
	NTPTimeZone=''
	NTPEnable=''
        NTPServer1=''
        NTPServer2=''
        DNSRacName=''

}

function OutputType(){
# Output
case $1 in

	Title) 
		printf "\033[1;36mThe configuration result file has added in your home folder and as follows:\033[0m\n" > /home/$Myself/ConfigurationResult.txt
		iDracHostnameInfo='iDrac Hostname'
		iDracIPInfo='iDrac IP'
		SerialNumberInfo='Serial Number'
		iDracUserInfo='New Account'
		RedundancyPolicy='PSU Balance'
		NTPTimeZone='Time Zone'
		NTPEnable='NTP Configuration'
		OutcomeInfo='Outcome'
		Output Table
		Output String
		;;

	Done)
		Output String
		;;

	Failure)
		OutcomeInfo="$(printf "\033[1;31m%-12s\033[0m" "Failure")"
		Output String
		;;
	
esac

}

function WriteCSV(){
# Write the result of configuration into the csv file
case $1 in
	Title)
		iDracHostnameInfo='iDrac Hostname'
		iDracIPInfo='iDrac IP'
		SerialNumberInfo='Serial number'
		HotSpareInfo='Hot Spare'
		RedundancyPolicy='Redundancy Policy'
		NTPEnable='NTP'
		NTPServer1='NTP Server1'
		NTPServer2='NTP Server2'
		NTPTimeZone='NTP Time Zone'
		DNSRacName='DNSRacName'
		echo "$iDracHostnameInfo,$iDracIPInfo,$SerialNumberInfo,$HotSpareInfo,$RedundancyPolicy,$NTPEnable,$NTPServer1,$NTPServer2,$NTPTimeZone,$DNSRacName" > /home/$Myself/ConfigurationResult.csv
		ClearInfo
		;;
	*)
		echo "$iDracHostnameInfo,$iDracIPInfo,$SerialNumberInfo,$HotSpareInfo,$RedundancyPolicy,$NTPEnable,$NTPServer1,$NTPServer2,$NTPTimeZone,$DNSRacName" >> /home/$Myself/ConfigurationResult.csv
		ClearInfo
		;;
esac
}

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
