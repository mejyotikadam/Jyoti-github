#!/bin/bash 
##This script creates list of numbers from input file.
## 
## 
## 
########################################################################################
isgfile="$1" # Output of symsg list -v -sid xxx
idevwwn="$2" # Output of symdev list -nomember -wwn -sid XXX
sid="$3"
DATE=`date +"%m.%d.%Y-%H:%M:%S"`
egrep  ""[0-9A-F]\{4,4\}"|Name:" $isgfile |egrep -v "Symmetrix|Last" > /tmp/sgjunk.txt ## Filter Input file for processing
fsgfile="/tmp/sgjunk.txt"
rm="/usr/bin/rm"
sgdevwwn="./SG_Devs_WWNs${sid}.txt"
if [ -f "$sgdevwwn" ]
then
	oren="${sgdevwwn}_old_${DATE}"
	echo "Moving old file $sgdevwwn to $oren.."
	mv $sgdevwwn $oren
fi

	echo "Please wait while script creates $sgdevwwn file ...."

while read line; 
do 
issg=$(echo $line|awk -F: '{print $1}'|awk '{$1=$1};1' |sed -e 's/\r//g')
#case  $dir in Director )
       	if [ "$issg" = "Name" ]
	then
		sgname=$(echo $line |awk -F: '{print $2}' |awk '{$1=$1};1' |sed -e 's/\r//g')
	else
		devid=$(echo $line |awk '{print $1}' |awk '{$1=$1};1' |sed -e 's/\r//g')	
		devtype=$(echo $line |awk '{print $(NF-2)}' |awk '{$1=$1};1' |sed -e 's/\r//g')	
		if [ "$devtype" = "Mir" ]
		then
			devtype="2-Way-Mir"
		fi
		devcap=$(echo $line |awk '{print $NF}' |awk '{$1=$1};1' |sed -e 's/\r//g')	
		if [ "xx$devid" != "xx" ]
		then
			devwwn=$(grep -w $devid $idevwwn |awk '{print $NF}' |awk '{$1=$1};1' |sed -e 's/\r//g')
			ismeta=$(grep -w $devid $idevwwn |awk '{print $(NF-1)}'|awk '{$1=$1};1' |sed -e 's/\r//g')
			if [ "$ismeta" != '(M)' ]
			then 
			ismeta='-'
			fi
		fi
		echo "$sgname $devid $devtype $devcap $devwwn $ismeta"  >> $sgdevwwn
	fi
done < $fsgfile
$rm $fsgfile
