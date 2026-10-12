# Honey Group : site vitrine et module Tourisme

Projet de stage. Il contient trois parties :

1. **Le site vitrine** (PHP, HTML, CSS, JavaScript), basé sur le design Figma de l'entreprise.
2. **Deux bases de données indépendantes** (MariaDB / MySQL) : `honey_hotels` et `honey_vehicules`.
3. **L'application Python / Django** qui lit ces deux bases : recherche, cotation, demandes de réservation et espace de gestion.

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

**Côté public**
- Recherche d'hôtels par destination, catégorie et équipements (liste de choix et cases à cocher).
- Recherche de véhicules par type, loueur et période.
- Barre de recherche globale (hôtels et véhicules) : plusieurs mots possibles.
- Fiche détaillée avec la grille des tarifs, et **calculateur de prix** : hôtel nuit par nuit, véhicule jour par jour, avec changement de saison au milieu d'un séjour.
- Vérification de la **disponibilité** des chambres et des véhicules.
- **Demande de réservation** : formulaire, référence unique (HTL-… ou VEH-…), page de confirmation, e-mail à l'équipe et accusé de réception au client.

**Côté équipe (`/gestion/`, connexion obligatoire)**
- Tableau de bord, avec le nombre de demandes en attente.
- Hôtels, véhicules et loueurs : ajouter, modifier, **archiver et restaurer** (pas de suppression définitive).
- Tarifs : types de chambre et stock, saisons, grille des prix, suppléments de pension, prix journaliers des véhicules.
- Réservations : liste filtrée par statut, détail d'une demande, **confirmer, refuser, annuler**, note interne, e-mail automatique au client à chaque décision.

## Règles de fonctionnement

- Prix en **Ariary (Ar)**. Hôtel : prix de la nuit de chaque saison, plus le supplément de pension **par nuit et par chambre**, multiplié par le nombre de chambres. Véhicule : jours entiers (premier et dernier compris), tarif avec ou sans chauffeur, multiplié par le nombre de véhicules.
- Le prix d'une demande est **recalculé par le serveur** et figé à l'enregistrement : modifier un tarif ensuite ne change pas les demandes déjà reçues.
- **Disponibilité** : chaque type de chambre a un stock (`nb_chambres`) et chaque véhicule un nombre d'exemplaires (`nb_exemplaires`). Seules les réservations **confirmées** occupent le stock. Une demande en attente ne bloque rien. La confirmation est refusée si le stock est insuffisant.
- Statuts : en attente, confirmée, refusée, annulée. Une demande refusée ou annulée est définitive.
- Les deux bases sont **indépendantes** : aucune clé étrangère ne les relie. Voir `database/MLD.md`.

## Sécurité

- Les fichiers `.env` (mots de passe) ne sont **jamais** publiés (`.gitignore`). Copiez `.env.example`.
- L'application se connecte à MariaDB avec un compte limité (`honey_app`, droits de lecture et d'écriture, sans droit de modifier la structure).
- L'espace de gestion est réservé aux comptes de l'équipe. Les formulaires sont protégés (CSRF), il y a un champ anti-robot et une limite de demandes par heure.
- Avant une mise en ligne : `DJANGO_DEBUG=0`, clé secrète définie, `ALLOWED_HOSTS` dans `backend/honey_site/settings.py`, HTTPS, un serveur WSGI (gunicorn ou autre) et de nouveaux mots de passe.

## Structure du projet

    assets/        CSS, JavaScript et images (partagés par le site vitrine et Django)
    components/    navbar, hero, footer du site vitrine
    pages/         pages du site vitrine
    data/          textes du site vitrine
    contact.php    formulaire de contact (PHPMailer, dans vendor/)
    backend/       application Django
        honey_site/   réglages, adresses, recherche globale, e-mails
        hotels/       module hôtels (modèles, recherche, cotation, disponibilité, réservation)
        vehicules/    module véhicules (même structure)
        gestion/      espace de gestion de l'équipe
        templates/    pages HTML de l'application
    database/      schema_complet.sql, donnees_demo.sql, utilisateur.sql, MLD.md, historique/

## Limites connues

- Pas de paiement en ligne : l'équipe confirme chaque demande.
- Le stock est un **nombre** : le système ne sait pas quelle chambre précise est occupée.
- Le site vitrine (port 8000) et l'application (port 8001) sont deux serveurs séparés, reliés par des liens dans leurs barres de navigation.
- Les données de démonstration (hôtels, loueurs, prix) sont inventées.
- Sans réglage SMTP, les e-mails s'affichent dans le terminal au lieu d'être envoyés.
