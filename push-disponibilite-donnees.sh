#!/usr/bin/env bash

plateforme="$1"
branch="$2"

# To prevent clashes
if [[ -f disponibilite-donnees-temp.csv ]]
then
  sleep $((1 + RANDOM % 30))
  git pull origin "$branch"
  cat disponibilite-donnees-temp.csv >> disponibilite-donnees.csv
  git commit -am "Update stats $plateforme"
  git push origin "$branch"
else
  echo "Pas de données de disponibilité des données."
fi