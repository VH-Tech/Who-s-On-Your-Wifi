#!/bin/bash
# Script to get network connected devices
echo Script to get network connected devices
#remove tmp files if exist
rm -f tmpIPlist.txt  myResult.txt
echo Below is list of Network Interfaces on your computer
ip -o -4 a | gawk '($2 != "lo") {print $2,$3,$4}'
myifName=$(ip -o -4 a | gawk '($2 != "lo") {print $2}')
#read -p 'On which Network you want to run device discovery : ' ifName

echo -n On which Network you want to run device discovery \($myifName\) :
read ifName


if [ -z "$ifName" ]
then
      ifName=$myifName
else
      echo
fi

echo Running script on your selection $ifName which has following IP address attached.
myNetwork=$(ip -o addr show dev $ifName | grep brd | gawk '{print $4}')
echo $myNetwork




echo found following IP addresses alive
sudo nmap -sn -oG - $myNetwork | grep Up | gawk '{print $2}' > tmpIPlist.txt
cat tmpIPlist.txt


read -p "Do you want to proceed with OS discovery? (y/n) " ask
  case $ask in
    y|Y) echo proceeding with OS discovery
			cat tmpIPlist.txt | while read line
			do
			echo finding details of $line
			sudo nmap -O -T4 $line | grep -e "scan report" -e MAC -e details | sed -z 's/\n/,/g;s/,$/\n/' >> myResult.txt
			done

			sed -i 's/^Nmap scan report for //g' myResult.txt
			cat myResult.txt
	
         exit ;;
    n|N) exit ;;
    *) ;;
  esac



echo this script ended at `date`
