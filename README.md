# Honey Group : site vitrine et base centralisée des partenaires

Projet de stage. Il contient trois parties :

1. **Le site vitrine** (PHP, HTML, CSS, JavaScript), basé sur le design Figma de l'entreprise.
2. **Deux bases de données indépendantes** (MariaDB / MySQL) : `honey_hotels` et `honey_vehicules`.
3. **L'application Python / Django** qui lit ces deux bases : recherche rapide, fiches détaillées avec calcul de cotation, et espace de gestion de l'équipe.

L'outil sert à **centraliser les informations des hôtels partenaires et des loueurs de véhicules**, pour retrouver
rapidement un partenaire et **calculer une cotation**. Ce n'est pas un site de réservation.

## Prérequis

- PHP 8.1 ou plus (pour le site vitrine et son formulaire de contact)
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

Pour générer la clé secrète : `python -c "import secrets; print(secrets.token_urlsafe(50))"`,
puis la placer dans `DJANGO_SECRET_KEY` (fichier `backend/.env`).

**3. Le site vitrine**

    cp .env.example .env                 # à la racine ; renseignez les réglages SMTP du formulaire de contact

## Lancer le projet

Deux serveurs, chacun dans son terminal :

    # Site vitrine (depuis la racine du projet)
    php -S 127.0.0.1:8000

    # Application Django (depuis backend/, environnement activé)
    python manage.py runserver 8001

| Page | Adresse |
|---|---|
| Site vitrine | http://127.0.0.1:8000 |
| Recherche d'hôtels | http://127.0.0.1:8001/hotels/ |
| Recherche de véhicules | http://127.0.0.1:8001/vehicules/ |
| Espace de gestion (équipe) | http://127.0.0.1:8001/gestion/ |

## Fonctionnalités

**Recherche et cotation**
- Recherche d'hôtels par destination, catégorie et équipements (liste de choix et cases à cocher).
- Recherche de véhicules par type, loueur et période.
- Barre de recherche globale (hôtels et véhicules) : plusieurs mots possibles.
- Fiche détaillée avec la grille des tarifs, et **calculateur de cotation** : hôtel nuit par nuit, véhicule jour par jour, avec changement de saison au milieu d'un séjour. La cotation s'imprime.

**Espace de gestion (`/gestion/`, connexion obligatoire)**
- Hôtels, véhicules et loueurs : ajouter, modifier, **archiver et restaurer** (pas de suppression définitive).
- Tarifs : types de chambre, saisons, grille des prix, suppléments de pension, prix journaliers des véhicules.
- **Paramètres : taux de change** euro / ariary.

## Devise

Tous les prix sont saisis et stockés en **Ariary (MGA)**. Partout où un prix est affiché, l'équivalent en **euros** est
ajouté (« 320 000 Ar ≈ 64,00 € »). Le taux se règle dans **Gestion, Paramètres** (« 1 € vaut … Ar ») : il est mis à jour par
l'équipe, selon le taux de référence choisi par l'entreprise. Tant qu'il n'est pas défini, un taux provisoire de 5 000 Ar est
utilisé et signalé.

## Règles de calcul

- Hôtel : prix de la nuit de chaque saison, plus le supplément de pension **par nuit et par chambre**, multiplié par le nombre de chambres.
- Véhicule : jours entiers (premier et dernier compris), tarif avec ou sans chauffeur, multiplié par le nombre de véhicules.
- Les deux bases sont **indépendantes** : aucune clé étrangère ne les relie. Voir `database/MLD.md`.

## Sécurité

- Les fichiers `.env` (mots de passe) ne sont **jamais** publiés (`.gitignore`). Copiez les `.env.example`.
- L'application se connecte à MariaDB avec un compte limité (`honey_app`, lecture et écriture, sans droit de modifier la structure).
- L'espace de gestion est réservé aux comptes de l'équipe, et les formulaires sont protégés (CSRF).
- Avant une mise en ligne : `DJANGO_DEBUG=0`, clé secrète définie, `ALLOWED_HOSTS` dans `backend/honey_site/settings.py`, HTTPS, un serveur WSGI (gunicorn ou autre) et de nouveaux mots de passe. Pensez aussi à décider si la recherche doit être réservée à l'équipe (connexion obligatoire).

## Structure du projet

    assets/        CSS, JavaScript et images (partagés par le site vitrine et Django)
    components/    navbar, hero, footer du site vitrine
    pages/         pages du site vitrine
    data/          textes du site vitrine
    contact.php    formulaire de contact (PHPMailer, dans vendor/)
    backend/       application Django
        honey_site/   réglages, adresses, recherche globale
        hotels/       module hôtels (modèles, recherche, cotation)
        vehicules/    module véhicules (même structure)
        gestion/      espace de gestion de l'équipe, taux de change
        templates/    pages HTML de l'application
    database/      schema_complet.sql, donnees_demo.sql, utilisateur.sql, MLD.md, historique/
    docs/          compte-rendu de mission

## Limites connues

- Le site vitrine (port 8000) et l'application (port 8001) sont deux serveurs séparés, reliés par des liens dans leurs barres de navigation.
- Les cotations calculées ne sont pas enregistrées : elles s'impriment depuis la fiche.
- Les données de démonstration (hôtels, loueurs, prix) sont inventées.
- Une première version contenait des demandes de réservation et un stock : elle est conservée dans l'étiquette Git `v1-avec-reservation`.

## Documentation

- Compte-rendu de mission : `docs/COMPTE_RENDU.md`
- Schéma relationnel des bases : `database/MLD.md`
