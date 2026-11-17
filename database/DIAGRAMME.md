# Diagrammes entité-relation (MCD / MLD)

Les deux bases sont **séparées et indépendantes** : il n'existe aucun lien entre les deux diagrammes.
Les diagrammes s'affichent automatiquement sur GitHub. Le détail de chaque colonne est dans `DICTIONNAIRE_DONNEES.md`.

## Base Hôtels (`honey_hotels`)

```mermaid
erDiagram
    DESTINATION ||--o{ HOTEL : accueille
    CATEGORIE_HOTEL ||--o{ HOTEL : classe
    HOTEL ||--o{ TYPE_CHAMBRE : contient
    HOTEL ||--o{ SAISON : definit
    HOTEL ||--o{ SUPPLEMENT_PENSION : propose
    HOTEL ||--o{ HOTEL_EQUIPEMENT : possede
    EQUIPEMENT ||--o{ HOTEL_EQUIPEMENT : decrit
    TYPE_CHAMBRE ||--o{ TARIF : possede
    SAISON ||--o{ TARIF : application
    HOTEL ||--o{ COTATION : concerne
    TYPE_CHAMBRE ||--o{ COTATION : utilise
    SAISON ||--o{ COTATION : periode
    SUPPLEMENT_PENSION |o--o{ COTATION : ajoute
    DESTINATION {
        int id PK
        string nom UK
    }
    CATEGORIE_HOTEL {
        int id PK
        string libelle UK
        int ordre
    }
    HOTEL {
        int id PK
        string code_externe UK
        string nom
        string localisation FK
        string categorie FK
        string contact
        text remarques
        bool actif
    }
    EQUIPEMENT {
        int id PK
        string libelle UK
    }
    HOTEL_EQUIPEMENT {
        int id_hotel PK
        int id_equipement PK
    }
    TYPE_CHAMBRE {
        int id PK
        int id_hotel FK
        string code_externe
        string libelle
        int capacite
    }
    SAISON {
        int id PK
        int id_hotel FK
        string libelle
        date date_debut
        date date_fin
    }
    TARIF {
        int id PK
        int id_type_chambre FK
        int id_saison FK
        decimal prix_nuitee
    }
    SUPPLEMENT_PENSION {
        int id PK
        int id_hotel FK
        string type_pension
        decimal prix_supplement
    }
    COTATION {
        int id PK
        int id_hotel FK
        int id_type_chambre FK
        int id_saison FK
        int id_supplement_pension FK
        int nombre_nuits
        decimal total_calcule
    }
```

## Base Véhicules (`honey_vehicules`)

```mermaid
erDiagram
    TYPE_VEHICULE ||--o{ VEHICULE : classe
    LOUEUR ||--o{ VEHICULE : propose
    LOUEUR ||--o{ SAISON_VEHICULE : definit
    VEHICULE ||--o{ TARIF_VEHICULE : possede
    SAISON_VEHICULE ||--o{ TARIF_VEHICULE : application
    TARIF_VEHICULE ||--o{ COTATION_VEHICULE : sert_a
    TYPE_VEHICULE {
        int id PK
        string libelle UK
        int ordre
    }
    LOUEUR {
        int id PK
        string code_externe UK
        string nom UK
        string telephone
        string email
        string localisation
        bool actif
    }
    VEHICULE {
        int id PK
        int id_loueur FK
        string code_externe UK
        string modele
        string categorie FK
        int capacite_passagers
        bool climatisation
        bool actif
    }
    SAISON_VEHICULE {
        int id PK
        int id_loueur FK
        string libelle
        date date_debut
        date date_fin
    }
    TARIF_VEHICULE {
        int id PK
        int id_vehicule FK
        int id_saison_vehicule FK
        bool inclus_chauffeur
        decimal prix_journalier
    }
    COTATION_VEHICULE {
        int id PK
        int id_vehicule FK
        int id_saison_vehicule FK
        bool inclus_chauffeur
        int nombre_jours
        int nombre_vehicules
        decimal total_calcule
    }
```

PK = clé primaire, FK = clé étrangère, UK = valeur unique.
