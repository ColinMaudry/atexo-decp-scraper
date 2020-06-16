#!/bin/sh

#sleep 5h

while IFS=, read -r name url status
do
	if [[ $status == "ok" ]]
	then
		echo "$name..."
		./download.sh "$name"
	fi
done
