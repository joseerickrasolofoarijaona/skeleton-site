# Compte-rendu de mission

**Stagiaire :** RASOLOFOARIJAONA José Erick (ENI, 1re année)
**Encadrant :** Robert Samson RAKOTOARISON (Gérant, Honey Group)

## Objectif confirmé

Une **base de données centralisée** des hôtels partenaires et des loueurs de voitures, pour remplacer la recherche dans des
documents imprimés et permettre de **coter rapidement**. Ce n'est pas un site de réservation en ligne, et il n'y a pas de gestion de stock.

## Livrables

- Deux bases séparées et indépendantes (MariaDB) : `honey_hotels` (8 tables) et `honey_vehicules` (5 tables).
- Schéma relationnel (`database/MLD.md`), scripts de création (`database/schema_complet.sql`) et jeu de données de démonstration (`database/donnees_demo.sql` : 9 hôtels, 10 véhicules).
- Application Python / Django : recherche multicritères, fiches détaillées, calculateur de cotation imprimable, espace de gestion (ajout, modification, archivage, tarifs).

## Évolutions après la réponse du 23 octobre

- **Retrait** de la réservation en ligne, de la vérification de disponibilité, du stock et des e-mails associés (version précédente conservée dans l'étiquette Git `v1-avec-reservation`).
- **Devise** : prix en Ariary (MGA), avec l'équivalent en euros partout où un prix est affiché. Le taux de change se règle dans Gestion, Paramètres.

## Points à valider

- Quel taux de change de référence utiliser, et à quelle fréquence le mettre à jour ?
- Le supplément de pension s'applique-t-il bien par nuit et par chambre ?
- Les saisons sont-elles propres à chaque hôtel et chaque loueur ?
- La recherche doit-elle être réservée à l'équipe (connexion obligatoire) ?

## Limites actuelles

- Le site vitrine (PHP) et l'application (Django) sont deux serveurs séparés ; leur intégration en un seul site reste à faire.
- Sur le site vitrine, les pages Services et Projets n'ont pas été reprises une à une d'après la maquette Figma.
- Les cotations ne sont pas enregistrées (impression seulement).
