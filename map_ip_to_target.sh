#!/bin/bash
### Written By : Jyoti Kadam to map the input file with Target Names 	#
### Use at your own risk 					     					#
### USAGE: script_name <File Name>	
### Commands to get INPUT file generated using script "vplex_get_feprts.sh"			     				#
###  #
######################################################################
file="./junk102"
while read -r line 
do 
	[[ "$line" =~ ^-.*$ ]] || [[ "$line" =~ ^Name.*$ ]] || [[ "$line" =~ ^VPlexcli.*$ ]] || [[ "$line" = "" ]] && continue

		engline=$(echo $line|awk -F/ '{print NF}');

		if [ "$engline" = "8" ]; then  engine=$(echo $line|sed 's/.$//')
		else 
			tgtport=$(echo $line|awk '{print $2}');
		fi; 
		tprt=$(echo $line| awk '{print $1}');
if [ "$tprt" = "target-port" ]
then 
		echo "$engine  $tgtport"; 
	fi
done < "$file"
