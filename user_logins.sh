#!/bin/bash 
##This script creates finds ONLINE/OFFLINE users.
## 
##By : Jyoti Kadam
##
########################################################################################
file="$1"
DATE=`date +"%m.%d.%Y-%H:%M:%S"`
grep -vE '^(\s*$|Identifier)' $file > /tmp/hlogins_junk.txt # Filter file by removing irrelevat lines.
ofile1="/tmp/hlogins_junk.txt"
egrep -v 'User-generated|^-' $ofile1 > /tmp/hlogins_junk1.txt # Filter file by removing irrelevat lines
ofile2="/tmp/hlogins_junk1.txt"
rm="/usr/bin/rm"
output="./HBA_logins_status.txt"
if [ -f "$output" ]
then
	obak="${output}_old_${DATE}"
	echo "Moving old file $output to $obak.."
	mv $output $obak
fi

	echo "Please wait while script creates $output file ...."

while read line; 
do 
#	[[ "$line" =~ ^-.*$ ]] || [[ "$line" =~ ^User-generated.*$ ]] || [[ "$line" = "" ]] && continue
# echo $line	
dir=$(echo $line|awk '{print $1}'|awk '{$1=$1};1' |sed -e 's/\r//g')
isdir=$(echo $line|awk -F: '{print $1}'|awk '{$1=$1};1' |sed -e 's/\r//g')
fldsno=$(echo $line|awk '{print NF}')
case  $dir in Director )
       	if [ "$isdir" = "Director Identification" ]
	then
		faid=$(echo $line |awk -F: '{print $NF}' |awk '{$1=$1};1' |sed -e 's/\r//g')
	elif [ "$isdir" = "Director Port" ]
	then 
		port=$(echo $line |awk -F: '{print $NF}' |awk '{$1=$1};1' |sed -e 's/\r//g')
	fi
		if [[ $port = "0" ]] || [[ $port = "1" ]]
		then		

		#echo "$faid:$port"
		faport=($faid:$port)
		#echo $faport
		fi
	continue

esac
if [[ "$fldsno" = "7" ]]
then 
	hwwn=$(echo $line|awk '{print $1}')
	halias=$(echo $line|awk '{print $3}')
	hinst=$(echo $line|awk '{print $4}')
	hlogin=$(echo $line|awk '{print $6"."$7}' |awk '{$1=$1};1' |sed -e 's/\r//g')
		#echo "$faport $hwwn $halias"_"$hinst $hlogin"
	if [ $hlogin = "Yes.Yes" ]
	then
		hstatus="Online"
	else
		hstatus="Offline"
	fi
		echo "$faport $hwwn $halias"_"$hinst $hstatus" >> $output
		#echo "$faport $hwwn $halias_$hinst $hlogin"
	#hwwn=$(echo $line| awk '{pr
 #echo "$faport $dir"
fi
       	#then 
	#	continue
       	#else 
	#	echo " $line"
	#fi
done < $ofile2

$rm $ofile1
$rm $ofile2

