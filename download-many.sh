#!/bin/bash

#sleep 5h
date=`date +%Y-%m-%dT%H:%M:%S`

for dir in xml acheteurs html
do
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

      python3 ./download.py --site "$name" -f -i &
  fi
done < plateformes.csv


# while IFS=, read -r name url status resource_id
# do
#   if [[ $status == "accessible" ]]
#     then
#       echo ""
#       echo "-----------------------"
#       echo "+ Publication de $name"
#       echo "-----------------------"
#       echo ""
#       ./publish.sh "$name" "$date"
#   fi
# done < plateformes.csv