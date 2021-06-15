# Récupération des DECP des plateformes Trust MPE (Atexo)

![Téléchargement](https://github.com/ColinMaudry/atexo-decp-scraper/workflows/CI/badge.svg)

Ce projet vise à développer un script permettant de télécharger facilement les données essentielles de la commande publique publiées sur les plateformes de marché développées par  Atexo.

Liste des plateformes identifiées : plateformes.csv

## Anomalies

Récolte en cours...

## Utiliser les script download.py et extractionAcheteurs.py

### Mettre en place l'environnement de développement

```
sudo apt-get install python3.6 python3-dev python3-venv
python3 -m venv myenv
source myenv/bin/activate
pip3 install -r requirements.txt
```

### Utiliser les scripts

Pour initialiser tous les sites connus

```
python extractionAcheteurs.py --site all
```

Pour obtenir de l'aide sur les options de la ligne de commande

```
python download.py --help
```

Pour téléchager un site, ex:Maximilien

```
python download.py --site marches.maximilien.fr
```

Pour télécharger tous les sites connus

```
python download.py --site all
```

Pour télécharger des données fraîches de 2020 pour deux site (ex:Maximilien et Megalis), avec un délais de 0.5 seconde entre chaque appel et 2 threads

```
python download.py --site marches.maximilien.fr marches.megalisbretagne.org --year 2020 --delay 0.5 --thread 2 --force_download
python download.py -s marches.maximilien.fr marches.megalisbretagne.org -y 2020 -d 0.5 -t 2 -f
```

## Licence

MIT
