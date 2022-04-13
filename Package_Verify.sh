#!/bin/bash

# for package verify

function PackageVerify(){
	PackageVerifyInfo=$(dpkg -s $1 2> /dev/null)
	PackageStatus=$(echo "$PackageVerifyInfo" | grep Status | awk -F: '{print $2}' |sed 's/^[\ ]//g')
	if [[ $PackageStatus != 'install ok installed' ]];then
		sudo apt-get install $1 > /dev/null
		echo "Installed Package $1 "
	fi
	echo 'Package Verify is done'
}
