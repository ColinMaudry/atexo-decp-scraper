#!/bin/bash

date=`date +%Y-%m-%dT%H:%M:%S`

export adsRoot=`pwd`

while IFS=, read -r name url status resource_id
do
  if [[ $status == "ok" ]]
    then
      echo ""
      echo "-----------------------"
      echo "+ $name"
      echo "-----------------------"
      echo ""


      ./download.sh "$name"
      ./merge.sh "$name" "$date"
      ./publish.sh "$name" "$date"
  fi
done < plateformes.csv
