# Dictionnaire de données : Honey Group

Généré automatiquement depuis les bases en service (`database/outils/generer_documentation.py`).
Tous les montants sont en **Ariary (MGA)**. Les deux bases sont indépendantes.

## Base Hôtels (`honey_hotels`)

### Table `destination`

Liste de référence des destinations. Un hôtel ne peut être rattaché qu'à une destination de cette liste.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `nom` | varchar(150) | non | unique |  | Nom de la destination (ex. Nosy Be). |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |

**Unicité**

- `uq_destination_nom` : (nom)

### Table `categorie_hotel`

Liste de référence des catégories d'hôtel (étoiles).

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `libelle` | varchar(50) | non | unique |  | Catégorie (ex. 4 étoiles). |
| `ordre` | smallint(5) unsigned | non |  | 99 | Ordre d'affichage dans les listes. |

**Unicité**

- `uq_categorie_hotel_libelle` : (libelle)

### Table `hotel`

Hôtels partenaires. Un hôtel n'est jamais supprimé : il est archivé (colonne actif).

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `code_externe` | varchar(40) | oui | unique | NULL | Code du partenaire dans le système de cotation existant (facultatif, unique). |
| `nom` | varchar(150) | non |  |  | Nom de l'hôtel. |
| `localisation` | varchar(150) | non | FK |  | Destination (liste de référence destination). |
| `categorie` | varchar(50) | oui | FK | NULL | Catégorie (liste de référence categorie_hotel). |
| `contact` | varchar(150) | oui |  | NULL | Téléphone ou e-mail. |
| `remarques` | text | oui |  | NULL | Remarques libres. |
| `actif` | tinyint(1) | non |  | 1 | 1 = en service, 0 = archivé. |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |
| `modifie_le` | datetime | non |  | current_timestamp() | Date de dernière modification (automatique). |

**Clés étrangères**

- `(categorie)` → `categorie_hotel(libelle)`
- `(localisation)` → `destination(nom)`

**Unicité**

- `uq_hotel_code_externe` : (code_externe)
- `uq_hotel_nom_localisation` : (nom, localisation)

**Contrôles**

- `actif` : ``actif` in (0,1)`

### Table `equipement`

Liste des équipements possibles (piscine, wi-fi, vue panoramique...).

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `libelle` | varchar(100) | non | unique |  | Nom de l'équipement (ex. Piscine). |

**Unicité**

- `uq_equipement_libelle` : (libelle)

### Table `hotel_equipement`

Équipements de chaque hôtel (liaison plusieurs-à-plusieurs).

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id_hotel` | int(10) unsigned | non | PK, FK |  | Clé étrangère vers hotel(id). |
| `id_equipement` | int(10) unsigned | non | PK, FK |  | Clé étrangère vers equipement(id). |

**Clés étrangères**

- `(id_equipement)` → `equipement(id)`
- `(id_hotel)` → `hotel(id)`

### Table `type_chambre`

Types de chambre proposés par chaque hôtel.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `id_hotel` | int(10) unsigned | non | FK |  | Clé étrangère vers hotel(id). |
| `code_externe` | varchar(40) | oui |  | NULL | Code du partenaire dans le système de cotation existant (facultatif, unique). |
| `libelle` | varchar(100) | non |  |  | Nom du type de chambre (ex. Chambre double). |
| `capacite` | tinyint(3) unsigned | non |  |  | Nombre de personnes que la chambre accueille. |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |
| `modifie_le` | datetime | non |  | current_timestamp() | Date de dernière modification (automatique). |

**Clés étrangères**

- `(id_hotel)` → `hotel(id)`

**Unicité**

- `uq_tc_code_externe` : (id_hotel, code_externe)
- `uq_tc_hotel_libelle` : (id_hotel, libelle)
- `uq_tc_id_hotel` : (id, id_hotel)

**Contrôles**

- `ck_tc_capacite` : ``capacite` > 0`

### Table `saison`

Périodes tarifaires propres à chaque hôtel (haute saison, basse saison...).

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `id_hotel` | int(10) unsigned | non | FK |  | Clé étrangère vers hotel(id). |
| `libelle` | varchar(100) | non |  |  | Nom de la saison (ex. Haute saison), propre à l'hôtel. |
| `date_debut` | date | non |  |  | Premier jour de la période. |
| `date_fin` | date | non |  |  | Dernier jour de la période (inclus). |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |
| `modifie_le` | datetime | non |  | current_timestamp() | Date de dernière modification (automatique). |

**Clés étrangères**

- `(id_hotel)` → `hotel(id)`

**Unicité**

- `uq_saison_hotel_libelle` : (id_hotel, libelle)
- `uq_saison_id_hotel` : (id, id_hotel)

**Contrôles**

- `ck_saison_dates` : ``date_fin` >= `date_debut``

### Table `tarif`

Prix de la nuitée, en Ariary (MGA), par type de chambre et par saison.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `id_type_chambre` | int(10) unsigned | non | FK |  | Clé étrangère vers type_chambre(id). |
| `id_saison` | int(10) unsigned | non | FK |  | Clé étrangère vers saison(id). |
| `prix_nuitee` | decimal(12,2) | non |  |  | Prix d'une nuit, en Ariary (MGA). |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |
| `modifie_le` | datetime | non |  | current_timestamp() | Date de dernière modification (automatique). |

**Clés étrangères**

- `(id_saison)` → `saison(id)`
- `(id_type_chambre)` → `type_chambre(id)`

**Unicité**

- `uq_tarif_chambre_saison` : (id_type_chambre, id_saison)

**Contrôles**

- `ck_tarif_prix` : ``prix_nuitee` >= 0`

### Table `supplement_pension`

Formules de pension et leur supplément par nuit et par chambre.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `id_hotel` | int(10) unsigned | non | FK |  | Clé étrangère vers hotel(id). |
| `type_pension` | varchar(50) | non |  |  | Formule de pension (ex. Demi-pension). |
| `prix_supplement` | decimal(12,2) | non |  |  | Supplément par nuit et par chambre, en Ariary (MGA). |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |
| `modifie_le` | datetime | non |  | current_timestamp() | Date de dernière modification (automatique). |

**Clés étrangères**

- `(id_hotel)` → `hotel(id)`

**Unicité**

- `uq_sp_hotel_type` : (id_hotel, type_pension)
- `uq_sp_id_hotel` : (id, id_hotel)

**Contrôles**

- `ck_sp_prix` : ``prix_supplement` >= 0`

### Table `cotation`

Cotations d'hôtel : réservée au raccordement avec le système de cotation.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `id_hotel` | int(10) unsigned | non | FK |  | Clé étrangère vers hotel(id). |
| `id_type_chambre` | int(10) unsigned | non | FK |  | Clé étrangère vers type_chambre(id). |
| `id_saison` | int(10) unsigned | non | FK |  | Clé étrangère vers saison(id). |
| `id_supplement_pension` | int(10) unsigned | oui | FK | NULL | Clé étrangère vers supplement_pension(id). |
| `nombre_nuits` | smallint(5) unsigned | non |  |  | Nombre de nuits. |
| `total_calcule` | decimal(14,2) | non |  |  | Total calculé, en Ariary (MGA). |

**Clés étrangères**

- `(id_hotel)` → `hotel(id)`
- `(id_saison, id_hotel)` → `saison(id, id_hotel)`
- `(id_supplement_pension, id_hotel)` → `supplement_pension(id, id_hotel)`
- `(id_type_chambre, id_hotel)` → `type_chambre(id, id_hotel)`

**Contrôles**

- `ck_cot_nuits` : ``nombre_nuits` > 0`
- `ck_cot_total` : ``total_calcule` >= 0`

### Vue `v_equipements_hotel`

Vue de lecture : équipements de chaque hôtel.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `hotel_id` | int(10) unsigned | non |  | 0 | Valeur reprise de la table d'origine. |
| `hotel_code` | varchar(9) | oui |  | NULL | Code technique mis en forme. Pour le rapprochement, utiliser le code externe. |
| `hotel_nom` | varchar(150) | non |  |  | Valeur reprise de la table d'origine. |
| `equipement` | varchar(100) | non |  |  | Valeur reprise de la table d'origine. |

### Vue `v_supplements_hotel`

Vue de lecture : suppléments de pension de chaque hôtel.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `hotel_id` | int(10) unsigned | non |  | 0 | Valeur reprise de la table d'origine. |
| `hotel_code` | varchar(9) | oui |  | NULL | Code technique mis en forme. Pour le rapprochement, utiliser le code externe. |
| `hotel_code_externe` | varchar(40) | oui |  | NULL | Valeur reprise de la table d'origine. |
| `hotel_nom` | varchar(150) | non |  |  | Valeur reprise de la table d'origine. |
| `hotel_actif` | tinyint(1) | non |  | 1 | Valeur reprise de la table d'origine. |
| `supplement_id` | int(10) unsigned | non |  | 0 | Valeur reprise de la table d'origine. |
| `type_pension` | varchar(50) | non |  |  | Formule de pension (ex. Demi-pension). |
| `prix_supplement_mga` | decimal(12,2) | non |  |  | Montant en Ariary (MGA). |
| `supplement_modifie_le` | datetime | non |  | current_timestamp() | Valeur reprise de la table d'origine. |

### Vue `v_tarifs_hotel`

Vue de lecture : tous les tarifs d'hôtel par type de chambre et par saison.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `hotel_id` | int(10) unsigned | non |  | 0 | Valeur reprise de la table d'origine. |
| `hotel_code` | varchar(9) | oui |  | NULL | Code technique mis en forme. Pour le rapprochement, utiliser le code externe. |
| `hotel_code_externe` | varchar(40) | oui |  | NULL | Valeur reprise de la table d'origine. |
| `hotel_nom` | varchar(150) | non |  |  | Valeur reprise de la table d'origine. |
| `destination` | varchar(150) | non |  |  | Valeur reprise de la table d'origine. |
| `categorie` | varchar(50) | oui |  | NULL | Valeur reprise de la table d'origine. |
| `hotel_actif` | tinyint(1) | non |  | 1 | Valeur reprise de la table d'origine. |
| `type_chambre_id` | int(10) unsigned | non |  | 0 | Valeur reprise de la table d'origine. |
| `type_chambre_code_externe` | varchar(40) | oui |  | NULL | Valeur reprise de la table d'origine. |
| `type_chambre` | varchar(100) | non |  |  | Valeur reprise de la table d'origine. |
| `capacite` | tinyint(3) unsigned | non |  |  | Nombre de personnes que la chambre accueille. |
| `saison_id` | int(10) unsigned | non |  | 0 | Valeur reprise de la table d'origine. |
| `saison` | varchar(100) | non |  |  | Valeur reprise de la table d'origine. |
| `saison_debut` | date | non |  |  | Valeur reprise de la table d'origine. |
| `saison_fin` | date | non |  |  | Valeur reprise de la table d'origine. |
| `prix_nuitee_mga` | decimal(12,2) | non |  |  | Montant en Ariary (MGA). |
| `tarif_modifie_le` | datetime | non |  | current_timestamp() | Valeur reprise de la table d'origine. |

## Base Véhicules (`honey_vehicules`)

### Table `type_vehicule`

Liste de référence des types de véhicule (4x4, minibus...).

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `libelle` | varchar(50) | non | unique |  | Type de véhicule (ex. 4x4). |
| `ordre` | smallint(5) unsigned | non |  | 99 | Ordre d'affichage dans les listes. |

**Unicité**

- `uq_type_vehicule_libelle` : (libelle)

### Table `loueur`

Loueurs de véhicules partenaires. Un loueur n'est jamais supprimé : il est archivé.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `code_externe` | varchar(40) | oui | unique | NULL | Code du partenaire dans le système de cotation existant (facultatif, unique). |
| `nom` | varchar(150) | non | unique |  | Nom du loueur. |
| `telephone` | varchar(50) | oui |  | NULL | Numéro de téléphone. |
| `email` | varchar(150) | oui |  | NULL | Adresse e-mail. |
| `localisation` | varchar(150) | oui |  | NULL | Ville du loueur. |
| `remarques` | text | oui |  | NULL | Remarques libres. |
| `actif` | tinyint(1) | non |  | 1 | 1 = en service, 0 = archivé. |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |
| `modifie_le` | datetime | non |  | current_timestamp() | Date de dernière modification (automatique). |

**Unicité**

- `uq_loueur_code_externe` : (code_externe)
- `uq_loueur_nom` : (nom)

**Contrôles**

- `actif` : ``actif` in (0,1)`

### Table `vehicule`

Flotte de chaque loueur.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `id_loueur` | int(10) unsigned | non | FK |  | Clé étrangère vers loueur(id). |
| `code_externe` | varchar(40) | oui | unique | NULL | Code du partenaire dans le système de cotation existant (facultatif, unique). |
| `modele` | varchar(100) | non |  |  | Modèle du véhicule (ex. Toyota Land Cruiser). |
| `categorie` | varchar(50) | non | FK |  | Type de véhicule (liste de référence type_vehicule). |
| `capacite_passagers` | tinyint(3) unsigned | non |  |  | Nombre de places passagers. |
| `climatisation` | tinyint(1) | non |  | 0 | 1 = climatisé, 0 = non. |
| `remarques` | text | oui |  | NULL | Remarques libres. |
| `actif` | tinyint(1) | non |  | 1 | 1 = en service, 0 = archivé. |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |
| `modifie_le` | datetime | non |  | current_timestamp() | Date de dernière modification (automatique). |

**Clés étrangères**

- `(id_loueur)` → `loueur(id)`
- `(categorie)` → `type_vehicule(libelle)`

**Unicité**

- `uq_vehicule_code_externe` : (code_externe)
- `uq_vehicule_loueur_modele` : (id_loueur, modele)

**Contrôles**

- `actif` : ``actif` in (0,1)`
- `ck_vehicule_capacite` : ``capacite_passagers` > 0`
- `ck_vehicule_clim` : ``climatisation` in (0,1)`

### Table `saison_vehicule`

Périodes tarifaires propres à chaque loueur.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `id_loueur` | int(10) unsigned | non | FK |  | Clé étrangère vers loueur(id). |
| `libelle` | varchar(100) | non |  |  | Nom de la saison (ex. Haute saison), propre au loueur. |
| `date_debut` | date | non |  |  | Premier jour de la période. |
| `date_fin` | date | non |  |  | Dernier jour de la période (inclus). |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |
| `modifie_le` | datetime | non |  | current_timestamp() | Date de dernière modification (automatique). |

**Clés étrangères**

- `(id_loueur)` → `loueur(id)`

**Unicité**

- `uq_sv_loueur_libelle` : (id_loueur, libelle)

**Contrôles**

- `ck_sv_dates` : ``date_fin` >= `date_debut``

### Table `tarif_vehicule`

Prix journalier, en Ariary (MGA), par véhicule, par saison, avec ou sans chauffeur.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `id_vehicule` | int(10) unsigned | non | FK |  | Clé étrangère vers vehicule(id). |
| `id_saison_vehicule` | int(10) unsigned | non | FK |  | Clé étrangère vers saison_vehicule(id). |
| `prix_journalier` | decimal(12,2) | non |  |  | Prix d'une journée de location, en Ariary (MGA). |
| `inclus_chauffeur` | tinyint(1) | non |  | 0 | 1 = avec chauffeur, 0 = sans chauffeur. |
| `cree_le` | datetime | non |  | current_timestamp() | Date de création de la ligne (automatique). |
| `modifie_le` | datetime | non |  | current_timestamp() | Date de dernière modification (automatique). |

**Clés étrangères**

- `(id_saison_vehicule)` → `saison_vehicule(id)`
- `(id_vehicule)` → `vehicule(id)`

**Unicité**

- `uq_tv_vehicule_saison_chauffeur` : (id_vehicule, id_saison_vehicule, inclus_chauffeur)

**Contrôles**

- `ck_tv_chauffeur` : ``inclus_chauffeur` in (0,1)`
- `ck_tv_prix` : ``prix_journalier` >= 0`

### Table `cotation_vehicule`

Cotations de véhicule : réservée au raccordement avec le système de cotation.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `id` | int(10) unsigned | non | PK |  | Identifiant technique (clé primaire). |
| `id_vehicule` | int(10) unsigned | non | FK |  | Clé étrangère vers tarif_vehicule(id_vehicule). |
| `id_saison_vehicule` | int(10) unsigned | non | FK |  | Clé étrangère vers tarif_vehicule(id_saison_vehicule). |
| `inclus_chauffeur` | tinyint(1) | non | FK | 0 | 1 = avec chauffeur, 0 = sans chauffeur. |
| `nombre_jours` | smallint(5) unsigned | non |  |  | Nombre de jours de location (premier et dernier jour inclus). |
| `nombre_vehicules` | smallint(5) unsigned | non |  | 1 | Nombre de véhicules loués. |
| `total_calcule` | decimal(14,2) | non |  |  | Total calculé, en Ariary (MGA). |

**Clés étrangères**

- `(id_vehicule, id_saison_vehicule, inclus_chauffeur)` → `tarif_vehicule(id_vehicule, id_saison_vehicule, inclus_chauffeur)`

**Contrôles**

- `ck_cv_jours` : ``nombre_jours` > 0`
- `ck_cv_total` : ``total_calcule` >= 0`
- `ck_cv_vehicules` : ``nombre_vehicules` > 0`

### Vue `v_tarifs_vehicule`

Vue de lecture : tous les tarifs de véhicule par saison et par option chauffeur.

| Colonne | Type | Null | Clé | Défaut | Description |
|---|---|---|---|---|---|
| `loueur_id` | int(10) unsigned | non |  | 0 | Valeur reprise de la table d'origine. |
| `loueur_code` | varchar(9) | oui |  | NULL | Code technique mis en forme. Pour le rapprochement, utiliser le code externe. |
| `loueur_code_externe` | varchar(40) | oui |  | NULL | Valeur reprise de la table d'origine. |
| `loueur_nom` | varchar(150) | non |  |  | Valeur reprise de la table d'origine. |
| `loueur_ville` | varchar(150) | oui |  | NULL | Valeur reprise de la table d'origine. |
| `loueur_actif` | tinyint(1) | non |  | 1 | Valeur reprise de la table d'origine. |
| `vehicule_id` | int(10) unsigned | non |  | 0 | Valeur reprise de la table d'origine. |
| `vehicule_code` | varchar(9) | oui |  | NULL | Code technique mis en forme. Pour le rapprochement, utiliser le code externe. |
| `vehicule_code_externe` | varchar(40) | oui |  | NULL | Valeur reprise de la table d'origine. |
| `modele` | varchar(100) | non |  |  | Modèle du véhicule (ex. Toyota Land Cruiser). |
| `type_vehicule` | varchar(50) | non |  |  | Valeur reprise de la table d'origine. |
| `capacite_passagers` | tinyint(3) unsigned | non |  |  | Nombre de places passagers. |
| `climatisation` | tinyint(1) | non |  | 0 | 1 = climatisé, 0 = non. |
| `vehicule_actif` | tinyint(1) | non |  | 1 | Valeur reprise de la table d'origine. |
| `saison_id` | int(10) unsigned | non |  | 0 | Valeur reprise de la table d'origine. |
| `saison` | varchar(100) | non |  |  | Valeur reprise de la table d'origine. |
| `saison_debut` | date | non |  |  | Valeur reprise de la table d'origine. |
| `saison_fin` | date | non |  |  | Valeur reprise de la table d'origine. |
| `inclus_chauffeur` | tinyint(1) | non |  | 0 | 1 = avec chauffeur, 0 = sans chauffeur. |
| `prix_journalier_mga` | decimal(12,2) | non |  |  | Montant en Ariary (MGA). |
| `tarif_modifie_le` | datetime | non |  | current_timestamp() | Valeur reprise de la table d'origine. |

