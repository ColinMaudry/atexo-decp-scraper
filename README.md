# Récupération des DECP des plateformes Trust MPE (Atexo)

Ce projet vise à développer un script permettant de télécharger facilement les données essentielles de la commande publique publiées sur les plateformes de marché développées par  Atexo.

Liste des plateformes identifiées :

- [marches.e-bourgogne.fr](http://marches.e-bourgogne.fr/?page=entreprise.EntrepriseRechercherListeMarches)
- [marches.cnes.fr](http:///?page=entreprise.EntrepriseRechercherListeMarches)
- [marchespublics.paysdelaloire.fr](http://marchespublics.paysdelaloire.fr/?page=entreprise.EntrepriseRechercherListeMarches)
- [marchespublics.hautsdefrance.fr](http://marchespublics.hautsdefrance.fr/?page=entreprise.EntrepriseRechercherListeMarches) (pas de données, remplacé par marchespublics596280.fr)
- [marchespublics596280.fr](http://marchespublics596280.fr/?page=entreprise.EntrepriseRechercherListeMarches)
- [marchespublics.grandest.fr](http://marchespublics.grandest.fr/?page=entreprise.EntrepriseRechercherListeMarches)
- [marches.departement13.fr](http://marches.departement13.fr/?page=entreprise.EntrepriseRechercherListeMarches)
- [marchespublics.lenord.fr](http://marchespublics.lenord.fr/?page=entreprise.EntrepriseRechercherListeMarches)
- [alsacemarchespublics.eu](http://alsacemarchespublics.eu/?page=entreprise.EntrepriseRechercherListeMarches)
- [mpe-marseille.local-trust.com](http://mpe-marseille.local-trust.com/?page=entreprise.EntrepriseRechercherListeMarches)
- [marches.megalisbretagne.org](http://marches.megalisbretagne.org/?page=entreprise.EntrepriseRechercherListeMarches)
- [marches.maximilien.fr](http://marches.maximilien.fr/?page=entreprise.EntrepriseRechercherListeMarches)

## Anomalies

### Centre National d'Etudes Spatiales (CNES) (marches.cnes.fr)

Aucune données accessible pour 2019 (erreur : "Cette liste des marchés n'a pas encore été publiée.")

[Lien vers le formulaire de recherche](https://marches.cnes.fr/?page=entreprise.EntrepriseRechercherListeMarches)

### Mégalis Bretagne (marches.megalisbretagne.org)

Pour les acheteurs publics suivants, l'erreur suivante est renvoyée

```
The controller must return a response (null given). Did you forget to add a return statement somewhere in your controller?
```

- Mairie d'Argentré du Plessis (`a5q`)
- MAIRIE DE LECOUSSE (`a8z`)
- Commune de Bonnemain (`d3z`)
- OFFICE DE TOURISME COMMUNAUTAIRE DE CONCARNEAU CORNOUAILLE AGGLOMERATION (`i8h`)
- Association Smile Smartgrids (`i8k`)
- CIAS_GUINGAMP_PAIMPOL AGGLOMERATION (`i8l`)
- CCAS DE GUEMENE PENFAO (`i8m`)
- CCAS de Maël-Carhaix (`i8n`)

## Région Pays de la Loire (marchespublics.paysdelaloire.fr)

Aucune données accessible pour 2019 (erreur : "Cette liste des marchés n'a pas encore été publiée.")

[Lien vers le formulaire de recherche](https://marchespublics.paysdelaloire.fr/?page=entreprise.EntrepriseRechercherListeMarches)

## Licence

MIT

## Utiliser le script download.sh
Pour téléchager Maximilien
```
./download.sh marches.maximilien.fr
```
## Utiliser les script download.py et extractionAcheteurs.py
### Mettre en place l'environnement de développement
```
apt-get install python3.6 python3-dev python3-venv
python3 -m venv myenv
source myenv/bin/activate
pip install -r requirements.txt
```
###Utiliser les script
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
