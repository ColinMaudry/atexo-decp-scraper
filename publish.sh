#!/bin/bash

plateforme="$1"
date="$2"

# fail on error
set -e

export api="https://www.data.gouv.fr/api/1"
export dataset_id="5f4d1921f7e627ef3ae26944"

#API_KEY configurée dans les options de build de CircleCI
api_key=$API_KEY

echo "Mise à jour de $plateforme.xml..."

# Récupération de l'id de ressource
while IFS=, read -r name url status resourceId
do
  if [[ $plateforme == "$name" ]]
    then
      resource_id=$resourceId
  fi
done < plateformes.csv

echo ""
echo "resource_id: $resource_id"

# Téléversement

if [[ -f "$adsRoot/xml/${plateforme}_${date}.xml" ]]
    then
    success=`curl "$api/datasets/$dataset_id/resources/${resource_id}/upload/" -F "file=@xml/${plateforme}_${date}.xml" -H "X-API-KEY: $api_key" | jq -r '.success | tostring'`
    echo ".success : $success"
    if [[ ! $success == "true" ]]
    then
        echo "Upload failed"
        exit 1
    else
        echo "Upload OK"
    fi
else
    echo "No file to upload"
    exit 1
fi
