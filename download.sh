#!/bin/bash

if [[ ! -d xml ]]
then
    mkdir -p xml/vides
    mkdir xml/html
fi

#for id in `jq -r '.[] | select(.disabled != true) | .id' megalis-acheteurs.json`
for id in a5q a8z d3z i8h i8k i8l i8m i8n
do
    #nom=`jq -r '.[] | select(.id == "$id") | .name' megalis-acheteurs.json | sed -r 's/[ ,\x27]/-/g'`
    for annee in 2019
    do
        curl -q "https://marches.megalisbretagne.org/app.php/api/v1/donnees-essentielles/contrat/xml-extraire-criteres/$id/0/1/$annee/false/false/false/false/false/false/false/false/false" > temp.xml

        # Vérification que
        # - le XML n'est pas vide
        # - c'est bien du XML est retourné (et pas une page HTML)
        if [[ `stat -c%s temp.xml` -lt 60 ]]
        then
            mv temp.xml xml/vides/${id}_${annee}.xml
        elif [[ `head -c 5 temp.xml` == "<!DOC" ]]
        then
            mv temp.xml xml/html/${id}_${annee}.xml
        else
            mv temp.xml xml/${id}_${annee}.xml
        fi
    done
done
