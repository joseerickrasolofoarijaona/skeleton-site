# Honey Group : bases de données Hôtels et Véhicules partenaires

Projet de stage. L'objectif est de **centraliser les informations des hôtels partenaires et des loueurs de véhicules**
dans deux bases de données **séparées et indépendantes**, pour retrouver rapidement un partenaire et préparer une cotation,
sans fouiller dans des documents imprimés. Les bases sont conçues pour être **reliées au système de cotation existant**
de l'entreprise (codes externes, vues de lecture).

## Contenu du dépôt

    database/      les deux bases de données (cœur du projet)
        schema_complet.sql        structure des deux bases (tables, contraintes, vues)
        donnees_reference.sql     listes obligatoires (destinations, catégories, équipements, types de véhicule)
        donnees_demo.sql          données de démonstration inventées (facultatif)
        utilisateur.sql           compte MariaDB de l'application (à adapter)
        vues_cotation.sql         vues de lecture pour le système de cotation
        DICTIONNAIRE_DONNEES.md   chaque table et chaque colonne documentée
        MLD.md                    schéma relationnel (clés primaires et étrangères)
        DIAGRAMME.md              diagrammes entité-relation
        tests/                    tests automatiques des règles des bases et de l'installation
        import/                   import de tarifs depuis des fichiers CSV
        outils/                   génération de la documentation et des scripts
        evolutions/               historique des évolutions de la structure
    backend/       outil de consultation et de gestion (Python / Django), limité aux deux modules
    docs/          compte-rendu de mission

## Installer les bases de données

Prérequis : MariaDB 10.6 ou plus, ou MySQL 8.

    cd database
    sudo mariadb < schema_complet.sql
    sudo mariadb < donnees_reference.sql
    sudo mariadb < donnees_demo.sql        # facultatif
    # Remplacez le mot de passe dans utilisateur.sql, puis :
    sudo mariadb < utilisateur.sql

Vérification : `bash tests/lancer_tests.sh` (tests des règles des bases).

## Raccordement au système de cotation

- **Codes de rapprochement** : `code_externe` (facultatif, unique) sur `hotel`, `type_chambre`, `loueur` et `vehicule`.
  C'est la clé de correspondance avec le système existant, sans lien entre les deux bases.
- **Dates** `cree_le` et `modifie_le` sur les tables de partenaires et de tarifs : repérer ce qui a changé depuis la dernière synchronisation.
- **Vues de lecture** (montants en Ariary, MGA) : `v_tarifs_hotel`, `v_supplements_hotel`, `v_equipements_hotel`, `v_tarifs_vehicule`.

Exemple : prix de la nuit d'une chambre à une date donnée.

    SELECT hotel_nom, type_chambre, saison, prix_nuitee_mga
    FROM v_tarifs_hotel
    WHERE hotel_nom = 'Le Palmier Doré' AND type_chambre = 'Chambre double'
      AND '2026-10-12' BETWEEN saison_debut AND saison_fin;

## Saisir les données réelles

Depuis des tableaux CSV (modèles fournis) : voir `database/import/LISEZMOI.md`. Un mode simulation vérifie tout sans rien enregistrer.

## L'outil de consultation (Django)

Il lit et met à jour les deux bases : recherche (hôtels : destination, catégorie, équipements ; véhicules : type, loueur, période),
fiches avec **calcul de cotation** imprimable, espace de gestion (ajout, modification, archivage, tarifs), prix en **Ariary (MGA)**
avec l'équivalent en **euros** (taux réglé dans Gestion, Paramètres).

    cd backend
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cp .env.example .env                   # puis remplissez le fichier .env
    python manage.py migrate
    python manage.py createsuperuser       # compte de l'équipe
    python manage.py runserver 8001        # http://127.0.0.1:8001

Prérequis : Python 3.12 ou plus ; sur Debian / Kali : `sudo apt install python3-venv python3-dev libmariadb-dev pkg-config build-essential`.

## Règles de calcul de la cotation

- Hôtel : prix de la nuit de chaque saison, plus le supplément de pension **par nuit et par chambre**, multiplié par le nombre de chambres.
- Véhicule : jours entiers (premier et dernier compris), tarif avec ou sans chauffeur, multiplié par le nombre de véhicules.

## Sécurité

- Les fichiers `.env` (mots de passe) ne sont **jamais** publiés. Copiez `backend/.env.example`.
- L'application se connecte avec un compte limité (`honey_app`, sans droit de modifier la structure).
- L'espace de gestion est réservé aux comptes de l'équipe. Avant une mise en ligne : `DJANGO_DEBUG=0`, clé secrète, HTTPS, mots de passe neufs.

## Historique

- La première mission (site vitrine « skeleton ») est archivée dans la branche `archive-skeleton`.
- Une version intermédiaire avec réservation et stock est conservée dans l'étiquette `v1-avec-reservation`.
