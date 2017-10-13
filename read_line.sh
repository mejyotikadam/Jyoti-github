#!/bin/bash 
file="./junk0"
while read -r line 
do 
	[[ "$line" =~ ^-.*$ ]] || [[ "$line" =~ ^Name.*$ ]] || [[ "$line" =~ ^.*back-end.*$ ]] || [[ "$line" =~ ^.*local-com.*$ ]] || [[ "$line" =~ ^.*down$ ]] || [[ "$line" = "" ]] && continue

		engline=$(echo $line|grep "engines" |awk -F/ '{print NF}');

	       	if [ "$engline" = "7" ]; then  engine=$line;
		else 
			port=$(echo $line|grep "front-end" | awk '{print $1}');
		fi; 
		feprt=$(echo $line|grep "front-end" | awk '{print $3}');
if [ "$feprt" = "front-end" ]
then 
		echo "ls -t $engine/$port::target-port "; 
	fi
done < "$file"
