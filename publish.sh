#!/bin/bash

plateforme="$1"
date="$2"

# fail on error
set -e

export api="https://www.data.gouv.fr/api/1"
export dataset_id="5f4d1921f7e627ef3ae26944"

#API_KEY configurée dans les options de build de CircleCI
api_key=$API_KEY
echo ${api_key:0:10}
exit 0

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

file="xml/${plateforme}_${date}.xml"

if [ -f "$file" -a `grep -E "<marche>|<contrat-concession>" $file | wc -l` -gt 0  ]
    then
      if [[ $DEBUG ]]; then echo "There is data to publish";  fi
      # If the resource doesn't exist yet, create it
      if [[ -z $resource_id ]]
        then
          if [[ $DEBUG ]]; then echo "No resource_id";  fi
           curl "$api/datasets/$dataset_id/upload/" -F "file=@$file" -H "X-API-KEY: $api_key" -H "Accept:application/json" -o ${plateforme}_upload.json 2> /dev/null
           success=`jq -r '.success' ${plateforme}_upload.json`
           new_resource_id=`jq -r '.id' ${plateforme}_upload.json`
          echo ".success : $success"
          echo "new resourceId for $plateforme is $new_resource_id"

          # Add resource id to platforms csv
          while IFS=, read -r name url status resourceId
            do
              if [[ $plateforme == "$name" ]]
                then
                  resourceId=$new_resource_id
              fi
              echo "$name,$url,$status,$resourceId" >> new_plateformes.csv
            done < plateformes.csv
            mv new_plateformes.csv plateformes.csv
        # Or update the existing one
        else
          success=`curl "${api}/datasets/${dataset_id}/resources/${resource_id}/upload/" -F "file=@${file}" -H "X-API-KEY: ${api_key}" "Accept:application/json" 2> /dev/null | jq -r '.success | tostring'`
          echo ".success : $success"
      fi
    if [[ ! $success == "true" ]]
    then
        echo "Upload failed"
        exit 1
    else
        echo "Upload OK"
    fi
else
    echo "No file to upload, or file has no data"
    exit 1
fi
