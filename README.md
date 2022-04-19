<h1>About</h1>

For iDrac/ILO Automation Configuration for Dell

This script can be:
 1. Add user for iDrac/iLO and set privilege
 2. Set PSU Redundancy and Hot Spare
 3. Get Serial Number and Mac address from iDrac
 4. Set Time Zone and NTP servers
 5. Set DNS iDrac Name and Static DNS Domain Name


<h1>Usage</h1>
0. Compelted the field in Hostname+ConfigField.txt

1. Download the software package from github
·sudo wget https://github.com/DolphQ/AutomaticallyConfigureiDrac.git·

2. Into package
`cd AutomaticallyConfigureiDrac/`

3. Add execute permission
`chmod +x iDrac_Configuration.sh`

4. Execute
`./iDrac_Configuration.sh`

<h1>Result</h1>

1. If Result is Failure, the configuration is failure
2. If Result is Done marded yellow, some configuration is done, some configuration is failed. You can check the detail in Details
3. If Result is Done marked green, all configurations is completed successfully.
