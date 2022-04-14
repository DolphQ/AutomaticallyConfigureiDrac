#!/bin/bash

# for package verify

function PackageVerify(){
	PackageVerifyInfo=$(dpkg -s $1 > /dev/null 2>1& )
	PackageStatus=$(echo "$PackageVerifyInfo" | grep Status | awk -F: '{print $2}' |sed 's/^[\ ]//g')
	if [[ $PackageStatus != 'install ok installed' ]];then
		echo "Installing Package $1 ..."
		sudo apt-get -y install $1 > /dev/null
	fi
	echo "$1 is already installed"
}
