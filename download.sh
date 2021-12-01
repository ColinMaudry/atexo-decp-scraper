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

mkdir -p $xmldir/vides
mkdir $xmldir/html
tempxml=xml/temp_${plateforme}.xml

if [[ -f acheteurs/${plateforme}.json ]]
then
  ids=`jq -r '.[] | .id' acheteurs/${plateforme}.json`
  total=0
  for id in $ids
    do
        nom=`jq --arg id "$id" -r '.[] | select(.id == $id) | .name' acheteurs/${plateforme}.json`
        nom_safe=`echo $nom | sed -r 's/[ ,\x27/]/-/g'`
        echo "$plateforme - $nom ($id)"

        for annee in 2018 2019 2020 2021
        do
            if [[ $DEBUG ]]; then echo "annee: $annee";  fi
            url="${baseurl}/app.php/api/v1/donnees-essentielles/contrat/xml-extraire-criteres/$id/0/1/$annee/false/false/false/false/false/false/false/false/false"

            date=`date +%Y-%m-%dT%H:%M:%S`

            # Don't stop on curl errors
            set +e
            if [[ $DEBUG ]]; then echo "Attempt to download XML...";  fi
            if [[ $DEBUG ]]; then curl -vL "$url" --connect-timeout 10 --max-time 60 -H "user-agent: atexo-decp-scraper" -o $tempxml 2>  >(grep "< HTTP/")
            else curl -vL "$url" --connect-timeout 10 --max-time 60 -H "user-agent: atexo-decp-scraper" -o $tempxml 2> /dev/null
            fi
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
                  echo $message >> disponibilite-donnees-temp.csv
                  log="${log}|    $annee:  0    "
              # - c'est bien du XML est retourné (et pas une page HTML (= page d'erreur))
              elif [[ `head -c 5 $tempxml` == "<!DOC" ]]
              then
                  if [[ $DEBUG ]]; then echo "HTML, probably an error";  fi
                  mv $tempxml "$xmldir/html/${id}_${nom_safe}_${annee}.xml"
                  echo "$plateforme,\"$nom\",$annee,erreur,$date" >> disponibilite-donnees-temp.csv
                  log="${log}|    $annee: erreur HTML    "
              else
                  if [[ $DEBUG ]]; then echo "XML with data retrieved!";  fi
                  num=`cat $tempxml | grep -E "<marche>|<contrat-concession>" | wc -l`
                  mv $tempxml "$xmldir/${id}_${nom_safe}_${annee}.xml"
                  echo "$plateforme,\"$nom\",$annee,$num,$date" >> disponibilite-donnees-temp.csv
                  log="${log}|    $annee: $num    "
                  total=$((num + total))
              fi
            else
              log="$log|    $annee: no temp.xml    "
            fi

      # Petite pause pour laisser respirer le serveur
      sleep 0.3
        done
        echo "$log | grand total: $total"
        log=""

    done
else
  echo "No acheteurs list for this plateforme"
fi

if [[ $2 == "publish" ]]
then
  ./publish.sh $plateforme $date
fi
