#!/bin/bash

# fail on error
set -e

name="$1"
date=`date +%Y-%m-%dT%H:%M:%S`

./download.sh "$name"

if [[ `ls -l xml/${name}/ | wc -l` -gt 3 ]]
then
  ./merge.sh "$name" "$date"
  ./publish.sh "$name" "$date"
else
  echo "No XML file downloaded for $name."
fi