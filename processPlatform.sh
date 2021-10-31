#!/bin/bash

name="$1"
date="$2"

./download.sh "$name"
./merge.sh "$name" "$date"
./publish.sh "$name" "$date"