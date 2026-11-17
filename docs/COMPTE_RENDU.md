# Compte-rendu de mission

**Stagiaire :** RASOLOFOARIJAONA José Erick (ENI, 1re année)
**Encadrant :** Robert Samson RAKOTOARISON (Gérant, Honey Group)

## Objectif

Concevoir et structurer proprement deux bases de données **séparées et indépendantes** (Hôtels et Véhicules partenaires)
d'après les MCD fournis, utilisables pour retrouver rapidement un partenaire, et **reliables au système de cotation existant**.

## Périmètre retenu

- Le skeleton (première mission) est hors périmètre : archivé dans la branche `archive-skeleton`.
- Pas de réservation en ligne, pas de gestion de stock. Prix en Ariary (MGA), avec équivalent en euros affiché.

## Livrables

- **Bases** : `database/schema_complet.sql`, `donnees_reference.sql`, `donnees_demo.sql` (9 hôtels, 10 véhicules inventés), `utilisateur.sql`.
- **Raccordement** : `code_externe` (hôtel, type de chambre, loueur, véhicule), dates de création et de modification, 4 vues de lecture.
- **Qualité** : listes de référence (destinations, catégories, types de véhicule) avec contraintes, tests automatiques des règles.
- **Documentation** : dictionnaire de données, MLD, diagrammes MCD, README.
- **Saisie** : import de tarifs depuis des fichiers CSV, avec simulation.
- **Outil de consultation** (`backend/`) : recherche, fiches avec cotation, gestion, tarifs.

## Points à valider avec l'équipe

- Technologie et mode de liaison du système de cotation existant (tables, vues, fichiers, API).
- Identifiants déjà utilisés par ce système pour les hôtels, loueurs, chambres et véhicules.
- Rôle des tables COTATION du MCD : à conserver, ou cotation entièrement gérée par le système existant ?
- Taux de change de référence et mode de mise à jour.
- Le supplément de pension s'applique-t-il bien par nuit et par chambre ? Les saisons sont-elles propres à chaque partenaire ?
