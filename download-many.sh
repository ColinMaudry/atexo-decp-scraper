#!/bin/bash

#sleep 5h

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
  fi
done < plateformes.csv
