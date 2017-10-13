#!/bin/bash  
### By : Jyoti Kadam to map Masking View, Storage Group, Port Group, Initiator Group #
### Parent/Child WN nos as well as Devices        	#
### Use : As is no guarantee/waranty				     #
### Usage : script_name.sh <SVs I/P File> <logins I/P>
### 
######################################################################
file="$1" # This file is output of symaccess list view -details command.
loginfile="$2" # This is file o/p of symaccess list logins command.
 egrep "Masking|Initiator|WWN|IG|Port|FA-|Storage|"^[0-9A-F]\{1,4\}"|Total" $file > /tmp/junkp
 pfile="/tmp/junkp"
 wnfile="/tmp/junk_iwwn.txt"
 wncount=0
 cigcount=0
 ###
 faloginscrpt="./VMAX_faport_hba_logins.sh" ## Another Script provides FA/WWN/ONLINE/OFFLINE Output
 falogoutput="./HBA_logins_status.txt" ## Output of faloginscrpt


 #echo "Calling FA logins Script."
 #if [ -f "$faloginscrpt" ]
 #then
#	 $faloginscrpt $loginfile
# else
#	 echo "FA Logins Script $faloginscrpt is not present."
# fi

while read -r line 
do
#	[[ "$line" =~ ^-.*$ ]] || [[ "$line" =~ "^[0-9A-F]\{1,4\}" ]] || [[ "$line" = "" ]]  && continue
tline=$(echo $line|awk -F: '{print $1}'|awk '{$1=$1};1')
devhex=$(echo $line|awk '{print $1}')

### Loop to skip Lines with Device ID's
  if [[ "$devhex" =~ ^[0-9A-Fa-f]{4} ]]
    then
	continue
    else

	if [ "$tline" = "Masking View Name" ]
	then
		mvname=$(echo $line|awk -F: '{print $2}'|awk '{$1=$1};1' |sed -e 's/\r//g')
	elif [ "$tline" = "Initiator Group Name" ]
	then 
		igname=$(echo $line|awk '{print $5}'|awk '{$1=$1};1'|sed -e 's/\*$//g')
	elif [ "$tline" = "WWN" ]
	then 
		wwnalias=$(echo $line|awk -F: '{print $2,$3}'|awk '{$1=$1};1')
		wwn=$(echo $wwnalias|awk '{print $1}')
		alias=$(echo $wwnalias|awk '{print $NF}'| sed -e 's/]//g')
		wwnfaids=$(grep -i $wwn $falogoutput |awk '{print $1}'| tr '\n' '/'|sed 's/.$//')
		wwnfasts=$(grep -i $wwn $falogoutput |awk '{print $NF}'| tr '\n' '/'|sed 's/.$//')
		((wncount++))
		#iwwn=$(echo "WWN-"$wcnt ":" $wwn)
		echo "WWN-$wncount ":" $wwn $alias $wwnfaids $wwnfasts"  >> $wnfile
	elif [ "$tline" = "IG" ]
	then 
		cigname=$(echo $line|awk '{print $3}')
		((cigcount++))
		echo "Child-IG-$cigcount ":" $cigname $igname" >> $wnfile
	elif [ "$tline" = "Port Group Name" ]
	then 
		wncount=0	
		cigcount=0	
		prtname=$(echo $line|awk -F: '{print $2}'|awk '{$1=$1};1')
	elif [ "$tline" = "Storage Group Name" ]
	then 
		sgname=$(echo $line|awk -F: '{print $2}'|awk '{$1=$1};1')
	fi
    fi
### Check if Multiple WWN nos 
	#if [ "$tline" = "WWN" ]
	#then 
	#	count 
### Print line for one masking view
	newmv=$(echo $line|awk '{print $1}')
	while [ "$newmv" = "Total" ]
	do	
		##
##		engline=$(echo $line|awk -F/ '{print NF}');
##
##		if [ "$engline" = "8" ]; then  engine=$(echo $line|sed 's/.$//')
##		else 
##			tgtport=$(echo $line|awk '{print $2}');
##		fi; 
##		tprt=$(echo $line| awk '{print $1}');
## if [ "$tprt" = "target-port" ]
## then 
		while read wline
		do
		iwwn=$(echo $wline |awk '{print $3}')
		ialias=$(echo $wline |awk '{print $4}')
		ifaids=$(echo $wline |awk '{print $(NF-1)}')
		ifasts=$(echo $wline |awk '{print $NF}')

		#echo -e "$mvname $igname $prtname $sgname" 
		echo "$mvname $sgname $prtname $igname $iwwn $ialias $ifaids $ifasts"
	#	cat /tmp/junk_iwwn.txt
		done < $wnfile

	#else 
	#	continue
newmv="none"
		if [  -f "$wnfile" ]
		then
		rm $wnfile
		fi
	done 
done < "$pfile"
rm $pfile

