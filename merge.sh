#!/bin/bash

plateforme="$1"
date="$2"
xmldir="$adsRoot/xml/$plateforme"

# Compte du nombre de marchés :

numMarches=`grep -E "<marche>|<contrat-concession>" $xmldir/*.xml | wc -l`

echo "$date : $plateforme publie $numMarches marchés"

# Fusion des XML en un fichier

output="$adsRoot/xml/${plateforme}_${date}.xml"

echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<marches>" > $output

for xml in `ls $xmldir/*.xml`
do
    head -n -1 $xml | tail -n +3 >> $output
done

echo "</marches>" >> $output
