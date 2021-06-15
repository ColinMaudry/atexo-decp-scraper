#!/bin/bash

#sleep 5h
date=`date +%Y-%m-%dT%H:%M:%S`

for dir in xml acheteurs html
  if [[ ! -d $dir ]]
  then
    mkdir $dir
  fi
done

while IFS=, read -r name url status resource_id
do
  if [[ $status == "accessible" ]]
    then
      echo ""
      echo "-----------------------"
      echo "+ $name"
      echo "-----------------------"
      echo ""

      python3 ./download.py --site "$name" -f -i
  fi
done < plateformes.csv

wait

while IFS=, read -r name url status resource_id
do
  if [[ $status == "accessible" ]]
    then
      echo ""
      echo "-----------------------"
      echo "+ Fusion des XML de $name"
      echo "-----------------------"
      echo ""

      ./merge.sh "$name" "$date"
      #./publish.sh "$name" "$date"
  fi
done < plateformes.csv