#!/bin/bash

plateforme="$1"
annee="$2"
baseurl=""

while IFS=, read -r id url
do
    if [[ "$id" == "$plateforme" ]]
    then
        baseurl="$url"
        break;
    fi
done < plateformes.csv

if [[ -z "$baseurl" ]]
then
    echo "ID de plateforme $plateforme introuvable."
    cat plateformes.csv
    exit 1
fi

xmldir="xml/$plateforme"

if [[ ! -d "$xmldir" ]]
then
    mkdir -p $xmldir/vides
    mkdir $xmldir/html
fi

for id in `jq -r '.[] | select(.disabled != true) | .id' acheteurs/${plateforme}.json`
do
    nom=`jq --arg id "$id" -r '.[] | select(.id == $id) | .name' acheteurs/${plateforme}.json | sed -r 's/[ ,\x27/]/-/g'`
    echo "$nom ($id)"
    curl "${baseurl}/app.php/api/v1/donnees-essentielles/contrat/xml-extraire-criteres/$id/0/1/$annee/false/false/false/false/false/false/false/false/false" > temp.xml 2> /dev/null

    # Vérification que
    # - le XML n'est pas vide
    # - c'est bien du XML est retourné (et pas une page HTML)
    if [[ `stat -c%s temp.xml` -lt 60 ]]
    then
        mv temp.xml "$xmldir/vides/${id}_${nom}_${annee}.xml"
        echo "> vide"
        echo ""
    elif [[ `head -c 5 temp.xml` == "<!DOC" ]]
    then
        mv temp.xml "$xmldir/html/${id}_${nom}_${annee}.xml"
        echo "> erreur"
        echo ""
    else
        mv temp.xml "$xmldir/${id}_${nom}_${annee}.xml"
        echo "> OK"
        echo ""
    fi


done

# Fusion des XML en un fichier

output="xml/$plateforme.xml"

echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<marches>" > $output

for xml in `ls $xmldir/*.xml`
do
    head -n -1 $xml | tail -n +3 >> $output
done

echo "</marches>" >> $output
