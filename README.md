# Récupération des DECP des plateformes Trust MPE (Atexo)

Ce projet vise à développer un script permettant de télécharger facilement les données essentielles de la commande publique publiées sur les plateformes de marché développées par  Atexo.

Liste des plateformes identifiées :

- marches.e-bourgogne.fr
- marches.cnes.fr
- marchespublics.paysdelaloire.fr
- marchespublics.hautsdefrance.fr
- marchespublics.grandest.fr
- marches.departement13.fr
- marchespublics.lenord.fr
- alsacemarchespublics.eu
- mpe-marseille.local-trust.com
- marches.megalisbretagne.org

## Anomalies

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

## Licence

MIT
