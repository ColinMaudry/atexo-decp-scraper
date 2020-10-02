#!/bin/bash

#sleep 5h
date=`date +%Y-%m-%dT%H:%M:%S`

while IFS=, read -r name url status
do
  if [[ $status == "ok" ]]
    then
      echo ""
      echo "-----------------------"
      echo "+ $name"
      echo "-----------------------"
      echo ""

      ./download.sh "$name"
      ./merge.sh "$name"
      ./publish.sh "$name" "$date"
  fi
done < plateformes.csv


