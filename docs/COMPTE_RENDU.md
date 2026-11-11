# Compte-rendu de mission

**Stagiaire :** RASOLOFOARIJAONA José Erick (ENI, 1re année)
**Encadrant :** Robert Samson RAKOTOARISON (Gérant, Honey Group)

## Objectif

Concevoir et structurer deux bases de données **séparées et indépendantes** (Hôtels et Véhicules partenaires) d'après les MCD
fournis, utilisables pour retrouver rapidement un partenaire et préparer une cotation, et pouvant être reliées au système de
cotation existant de l'entreprise.

## Périmètre retenu

- Le skeleton (première mission) est **hors périmètre** : il est archivé dans la branche `archive-skeleton`.
- Pas de réservation en ligne, pas de gestion de stock.
- Prix en Ariary (MGA), avec équivalent en euros affiché.

## Livrables

- `database/` : scripts de création, jeu de données de démonstration, schéma relationnel (`MLD.md`).
- `backend/` : application de consultation et de gestion limitée aux deux modules (recherche multicritères, fiches avec cotation, ajout, modification, archivage, tarifs).

## Points à valider

- Technologie et mode de liaison du système de cotation existant (tables, vues, fichiers, API).
- Identifiants déjà utilisés par ce système pour les hôtels, loueurs, chambres et véhicules.
- Rôle des tables COTATION du MCD : à conserver, ou cotation entièrement gérée par le système existant ?
- Taux de change de référence, et gestion du taux (système existant ou base).
- Le supplément de pension s'applique-t-il bien par nuit et par chambre ? Les saisons sont-elles propres à chaque partenaire ?
