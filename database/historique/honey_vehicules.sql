-- =====================================================================
-- Honey Group - Base de données "Loueurs & Véhicules partenaires" (B2B)
-- SGBD : MySQL / MariaDB
-- Base indépendante : aucune clé étrangère vers une autre base.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS honey_vehicules
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE honey_vehicules;


-- LOUEUR
CREATE TABLE IF NOT EXISTS loueur (
    id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom           VARCHAR(150) NOT NULL,
    telephone     VARCHAR(50)  NULL,
    email         VARCHAR(150) NULL,
    localisation  VARCHAR(150) NULL,
    remarques     TEXT         NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_loueur_nom (nom)
) ENGINE=InnoDB;


-- VEHICULE
CREATE TABLE IF NOT EXISTS vehicule (
    id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_loueur           INT UNSIGNED NOT NULL,
    modele              VARCHAR(100) NOT NULL,
    categorie           VARCHAR(50)  NOT NULL,
    capacite_passagers  TINYINT UNSIGNED NOT NULL,
    climatisation       TINYINT(1) NOT NULL DEFAULT 0,
    remarques           TEXT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_vehicule_loueur_modele (id_loueur, modele),
    CONSTRAINT ck_vehicule_capacite CHECK (capacite_passagers > 0),
    CONSTRAINT ck_vehicule_clim CHECK (climatisation IN (0, 1)),
    CONSTRAINT fk_vehicule_loueur FOREIGN KEY (id_loueur)
        REFERENCES loueur (id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- SAISON_VEHICULE (id_loueur ajouté par rapport au MCD)
CREATE TABLE IF NOT EXISTS saison_vehicule (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_loueur   INT UNSIGNED NOT NULL,
    libelle     VARCHAR(100) NOT NULL,
    date_debut  DATE NOT NULL,
    date_fin    DATE NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_sv_loueur_libelle (id_loueur, libelle),
    CONSTRAINT ck_sv_dates CHECK (date_fin >= date_debut),
    CONSTRAINT fk_sv_loueur FOREIGN KEY (id_loueur)
        REFERENCES loueur (id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- TARIF_VEHICULE
CREATE TABLE IF NOT EXISTS tarif_vehicule (
    id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_vehicule         INT UNSIGNED NOT NULL,
    id_saison_vehicule  INT UNSIGNED NOT NULL,
    prix_journalier     DECIMAL(12,2) NOT NULL,
    inclus_chauffeur    TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uq_tv_vehicule_saison_chauffeur
        (id_vehicule, id_saison_vehicule, inclus_chauffeur),
    CONSTRAINT ck_tv_prix CHECK (prix_journalier >= 0),
    CONSTRAINT ck_tv_chauffeur CHECK (inclus_chauffeur IN (0, 1)),
    CONSTRAINT fk_tv_vehicule FOREIGN KEY (id_vehicule)
        REFERENCES vehicule (id) ON DELETE CASCADE,
    CONSTRAINT fk_tv_saison FOREIGN KEY (id_saison_vehicule)
        REFERENCES saison_vehicule (id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- COTATION_VEHICULE
-- inclus_chauffeur ajouté : il permet de retrouver le bon tarif.
-- La clé étrangère composée garantit qu'un tarif existe pour cette
-- combinaison véhicule + saison + chauffeur.
CREATE TABLE IF NOT EXISTS cotation_vehicule (
    id                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_vehicule         INT UNSIGNED NOT NULL,
    id_saison_vehicule  INT UNSIGNED NOT NULL,
    inclus_chauffeur    TINYINT(1) NOT NULL DEFAULT 0,
    nombre_jours        SMALLINT UNSIGNED NOT NULL,
    nombre_vehicules    SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    total_calcule       DECIMAL(14,2) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT ck_cv_jours CHECK (nombre_jours > 0),
    CONSTRAINT ck_cv_vehicules CHECK (nombre_vehicules > 0),
    CONSTRAINT ck_cv_total CHECK (total_calcule >= 0),
    CONSTRAINT fk_cv_tarif FOREIGN KEY
        (id_vehicule, id_saison_vehicule, inclus_chauffeur)
        REFERENCES tarif_vehicule
        (id_vehicule, id_saison_vehicule, inclus_chauffeur)
) ENGINE=InnoDB;
