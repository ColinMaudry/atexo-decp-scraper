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

if [[ -f acheteurs/${plateforme}.json ]]
then
  ids=`jq -r '.[] | .id' acheteurs/${plateforme}.json`
  for id in $ids
    do
        nom=`jq --arg id "$id" -r '.[] | select(.id == $id) | .name' acheteurs/${plateforme}.json`
        nom_safe=`echo $nom | sed -r 's/[ ,\x27/]/-/g'`
        echo "$nom ($id)"

        for annee in 2018 2019 2020 2021
        do
            if [[ $DEBUG ]]; then echo "annee: $annee";  fi
            url="${baseurl}/app.php/api/v1/donnees-essentielles/contrat/xml-extraire-criteres/$id/0/1/$annee/false/false/false/false/false/false/false/false/false"

            date=`date +%Y-%m-%dT%H:%M:%S`

            if [[ $DEBUG ]]; then echo "Attempt to download XML...";  fi
            set +e
            curl -vL "$url" --connect-timeout 10 --max-time 60 -o $tempxml 2>  >(grep "< HTTP/")
            set -e
            # Vérification que
            # - le XML n'est pas vide

            if [[ -f $tempxml ]]
            then
              if [[ `cat $tempxml | grep -E "<marche>|<contrat-concession>" | wc -l` -eq 0 ]]
              then
                  if [[ $DEBUG ]]; then echo "XML downloaded, but empty";  fi
                  mv $tempxml "$xmldir/vides/${id}_${nom_safe}_${annee}.xml"
                  message="$plateforme,\"$nom\",$annee,0,$date"
                  echo $message >> disponibilite-donnees.csv
                  echo "- $annee:  0"
              # - c'est bien du XML est retourné (et pas une page HTML (= page d'erreur))
              elif [[ `head -c 5 $tempxml` == "<!DOC" ]]
              then
                  if [[ $DEBUG ]]; then echo "HTML, probably an error";  fi
                  mv $tempxml "$xmldir/html/${id}_${nom_safe}_${annee}.xml"
                  echo "$plateforme,\"$nom\",$annee,erreur,$date" >> disponibilite-donnees.csv
                  echo "- $annee:  erreur HTML"
              else
                  if [[ $DEBUG ]]; then echo "XML with data retrieved!";  fi
                  num=`cat $tempxml | grep -E "<marche>|<contrat-concession>" | wc -l`
                  mv $tempxml "$xmldir/${id}_${nom_safe}_${annee}.xml"
                  echo "$plateforme,\"$nom\",$annee,$num,$date" >> disponibilite-donnees.csv
                  echo "- $annee:   $num"
              fi
            else
              echo "No temp.xml"
            fi

      # Petite pause pour laisser respirer le serveur
      sleep 0.3
        done

    done
else
  echo "No acheteurs list for this plateforme"
fi

if [[ $2 == "publish" ]]
then
  ./publish.sh $plateforme $date
fi
