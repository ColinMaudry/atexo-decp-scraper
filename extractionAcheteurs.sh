#!/bin/bash

# Le point de départ : un élément <option> par ligne :
# <option value="b4b">CCAS de Meudon</option>

# Résultat :
# Un array JSON d'objets :
#


plateforme=$1
html=$2

temp=`cat $html | sed 's/<option value=//g' | sed 's/<\/option>//g' | sed 's/>/,"name": "/g' | sed -r 's/^/{"id": /g' | sed -r 's/\t//g'`

json1=`echo "$temp" | head -n -1 | sed -r 's/$/"},/g'`
json2=`echo "$temp" | tail -n 1 | sed -r 's/$/"}/g'`

echo "[ ${json1} ${json2} ]" | jq . > $plateforme.json
