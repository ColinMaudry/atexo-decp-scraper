#!/bin/bash

# fail on error
set -e

date=`date +%Y-%m-%dT%H:%M:%S`

export adsRoot=`pwd`

while IFS=, read -r name url status resource_id
do
  if [[ $status == "accessible" ]]
    then
      echo ""
      echo "-----------------------"
      echo "+ $name"
      echo "-----------------------"
      echo ""


      ./processPlatform.sh "$name" "$date"
  fi
done < plateformes.csv
