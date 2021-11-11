#!/bin/bash

# fail on error
set -e

plateforme="$1"
baseurl=""

while IFS=, read -r id url statut
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

# Nettoyage avant téléchargement
if [[ -d "$xmldir" ]]
then
 rm -r $xmldir
fi

# Suppressiond des données de disponibilité pour la plateforme courante
cat disponibilite-donnees.csv | grep -v "$plateforme," > temp.csv
mv temp.csv disponibilite-donnees.csv

mkdir -p $xmldir/vides
mkdir $xmldir/html
tempxml=xml/temp_${plateforme}.xml

for id in `jq -r '.[] | .id' acheteurs/${plateforme}.json`
do
    nom=`jq --arg id "$id" -r '.[] | select(.id == $id) | .name' acheteurs/${plateforme}.json`
    nom_safe=`echo $nom | sed -r 's/[ ,\x27/]/-/g'`
    echo "$nom ($id)"

    for annee in 2018 2019 2020 2021
    do

        url="${baseurl}/app.php/api/v1/donnees-essentielles/contrat/xml-extraire-criteres/$id/0/1/$annee/false/false/false/false/false/false/false/false/false"

        date=`date +%Y-%m-%dT%H:%M:%S`

        curl "$url" --connect-timeout 10 --max-time 60 > $tempxml 2> /dev/null

        # Vérification que
        # - le XML n'est pas vide

        if [[ -f $tempxml ]]
        then
          if [[ `cat $tempxml | grep -E "<marche>|<contrat-concession>" | wc -l` -eq 0 ]]
          then
              mv $tempxml "$xmldir/vides/${id}_${nom_safe}_${annee}.xml"
              echo "$plateforme,\"$nom\",$annee,0,$date" >> disponibilite-donnees.csv
          # - c'est bien du XML est retourné (et pas une page HTML (= page d'erreur))
          elif [[ `head -c 5 $tempxml` == "<!DOC" ]]
          then
              mv $tempxml "$xmldir/html/${id}_${nom_safe}_${annee}.xml"
              echo "$plateforme,\"$nom\",$annee,erreur,$date" >> disponibilite-donnees.csv
          else
              num=`cat $tempxml | grep -E "<marche>|<contrat-concession>" | wc -l`
              mv $tempxml "$xmldir/${id}_${nom_safe}_${annee}.xml"
              echo "$plateforme,\"$nom\",$annee,$num,$date" >> disponibilite-donnees.csv
          fi
        else
          echo "No temp.xml"
        fi

	# Petite pause pour laisser respirer le serveur
	sleep 0.3
    done

done

if [[ $2 == "publish" ]]
then
  ./publish.sh $plateforme $date
fi
