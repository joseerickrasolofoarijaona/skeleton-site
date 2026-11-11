# Honey Group : bases de données Hôtels et Véhicules partenaires

Projet de stage. L'objectif est de **centraliser les informations des hôtels partenaires et des loueurs de véhicules**
dans deux bases de données **séparées et indépendantes**, pour retrouver rapidement un partenaire et calculer une cotation,
sans fouiller dans des documents imprimés.

Le dépôt contient :

1. **Les deux bases de données** (MariaDB / MySQL) : `honey_hotels` et `honey_vehicules`, d'après les MCD fournis.
2. **Une application Python / Django** qui les consulte et les met à jour : recherche multicritères, fiches avec calcul de cotation, espace de gestion de l'équipe.

## Prérequis

- Python 3.12 ou plus (testé avec Python 3.14)
- MariaDB 10.6 ou plus, ou MySQL 8
- Sur Debian / Kali : `sudo apt install python3-venv python3-dev libmariadb-dev pkg-config build-essential`

## Installation

**1. Les bases de données**

    cd database
    # Remplacez d'abord le mot de passe dans utilisateur.sql
    sudo mariadb < schema_complet.sql
    sudo mariadb < donnees_demo.sql      # facultatif : données de démonstration (inventées)
    sudo mariadb < utilisateur.sql

**2. L'application Django**

    cd backend
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cp .env.example .env                 # puis remplissez le fichier .env
    python manage.py migrate
    python manage.py createsuperuser     # compte de l'équipe (espace de gestion)
    python manage.py runserver 8001

Pour générer la clé secrète : `python -c "import secrets; print(secrets.token_urlsafe(50))"`,
puis la placer dans `DJANGO_SECRET_KEY` (fichier `backend/.env`).

| Page | Adresse |
|---|---|
| Recherche d'hôtels | http://127.0.0.1:8001/hotels/ |
| Recherche de véhicules | http://127.0.0.1:8001/vehicules/ |
| Espace de gestion (équipe) | http://127.0.0.1:8001/gestion/ |

## Fonctionnalités

**Recherche et cotation**
- Hôtels : destination, catégorie, équipements. Véhicules : type, loueur, période.
- Barre de recherche globale (hôtels et véhicules).
- Fiche détaillée avec la grille des tarifs et **calculateur de cotation** imprimable : hôtel nuit par nuit, véhicule jour par jour, avec changement de saison au milieu d'un séjour.

**Espace de gestion (connexion obligatoire)**
- Hôtels, véhicules et loueurs : ajouter, modifier, **archiver et restaurer** (pas de suppression définitive).
- Tarifs : types de chambre, saisons, grille des prix, suppléments de pension, prix journaliers des véhicules.
- Paramètres : taux de change euro / ariary.

## Devise

Les prix sont saisis et stockés en **Ariary (MGA)**. L'équivalent en **euros** est affiché à côté (« 320 000 Ar ≈ 64,00 € »)
avec un taux réglé dans Gestion, Paramètres. Tant qu'il n'est pas défini, un taux provisoire de 5 000 Ar est utilisé et signalé.

## Règles de calcul

- Hôtel : prix de la nuit de chaque saison, plus le supplément de pension **par nuit et par chambre**, multiplié par le nombre de chambres.
- Véhicule : jours entiers (premier et dernier compris), tarif avec ou sans chauffeur, multiplié par le nombre de véhicules.
- Les deux bases sont **indépendantes** : aucune clé étrangère ne les relie. Voir `database/MLD.md`.

## Sécurité

- Les fichiers `.env` (mots de passe) ne sont **jamais** publiés (`.gitignore`). Copiez `backend/.env.example`.
- L'application se connecte à MariaDB avec un compte limité (`honey_app`, sans droit de modifier la structure).
- L'espace de gestion est réservé aux comptes de l'équipe, et les formulaires sont protégés (CSRF).
- Avant une mise en ligne : `DJANGO_DEBUG=0`, clé secrète définie, `ALLOWED_HOSTS`, HTTPS, un serveur WSGI et de nouveaux mots de passe.

## Structure du projet

    backend/       application Django
        honey_site/   réglages, adresses, recherche globale
        hotels/       module hôtels (modèles, recherche, cotation)
        vehicules/    module véhicules (même structure)
        gestion/      espace de gestion de l'équipe, taux de change
        templates/    pages HTML
        static/css/   feuilles de style
    database/      schema_complet.sql, donnees_demo.sql, utilisateur.sql, MLD.md, historique/
    docs/          compte-rendu de mission

## Historique

- La première mission (site vitrine « skeleton ») est conservée dans la branche `archive-skeleton`.
- Une version intermédiaire avec réservation et stock est conservée dans l'étiquette `v1-avec-reservation`.

## Documentation

- Schéma relationnel des bases : `database/MLD.md`
- Compte-rendu de mission : `docs/COMPTE_RENDU.md`
