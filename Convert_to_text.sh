#!/bin/bash 
## This script spits only formats data to be used for webapplication input.
## By: Jyoti Kadam
###################################################################
file="/tmp/logins_junk.txt"
grep -vE '^(\s*$|Identifier)' $file > /tmp/plogins_junk.txt
egrep -v 'User-generated|^-' /tmp/plogins_junk.txt > /tmp/plogins_junk1.txt
while read line; 
do 
#	[[ "$line" =~ ^-.*$ ]] || [[ "$line" =~ ^User-generated.*$ ]] || [[ "$line" = "" ]] && continue
# echo $line	
dir=$(echo $line|awk '{print $1}'|awk '{$1=$1};1' |sed -e 's/\r//g')
isdir=$(echo $line|awk -F: '{print $1}'|awk '{$1=$1};1' |sed -e 's/\r//g')
case  $dir in Director )
       	if [ "$isdir" = "Director Identification" ]
	then
		faid=$(echo $line |awk -F: '{print $NF}' |awk '{$1=$1};1' |sed -e 's/\r//g')
	elif [ "$isdir" = "Director Port" ]
	then 
		port=$(echo $line |awk -F: '{print $NF}' |awk '{$1=$1};1' |sed -e 's/\r//g')
	fi
	echo "$faid:$port"
	#echo $line
	continue
esac
       	#then 
	#	continue
       	#else 
	#	echo " $line"
	#fi
done < plogins_junk.txt
