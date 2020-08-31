#!/bin/bash

plateforme=$1
date=$2

# fail on error
set -e

export api="https://www.data.gouv.fr/api/1"
export dataset_id="5f4d1921f7e627ef3ae26944"

#API_KEY configurée dans les options de build de CircleCI
api_key=$API_KEY

echo "Mise à jour de $plateforme.xml..."

# Récupération de l'id de ressource
resource_id=`curl -L "https://www.data.gouv.fr/api/1/datasets/$dataset_id" | jq -r --arg title "$plateforme.xml" '.resources[] | select (.title == $title) | .id'`

# Téléversement
curl "$api/datasets/$dataset_id/resources/${resource_id}/upload/" -F "file=@xml/${plateforme}_${date}.xml" -H "X-API-KEY: $api_key"
