-- =====================================================================
-- Honey Group - Base de données "Hôtels partenaires" (B2B)
-- SGBD : MySQL / MariaDB
-- Base indépendante : aucune clé étrangère vers une autre base.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS honey_hotels
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE honey_hotels;


-- HOTEL
CREATE TABLE IF NOT EXISTS hotel (
    id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom           VARCHAR(150) NOT NULL,
    localisation  VARCHAR(150) NOT NULL,
    categorie     VARCHAR(50)  NULL,
    contact       VARCHAR(150) NULL,
    remarques     TEXT         NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_hotel_nom_localisation (nom, localisation)
) ENGINE=InnoDB;


-- TYPE_CHAMBRE
CREATE TABLE IF NOT EXISTS type_chambre (
    id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_hotel  INT UNSIGNED NOT NULL,
    libelle   VARCHAR(100) NOT NULL,
    capacite  TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_tc_hotel_libelle (id_hotel, libelle),
    UNIQUE KEY uq_tc_id_hotel (id, id_hotel),
    CONSTRAINT ck_tc_capacite CHECK (capacite > 0),
    CONSTRAINT fk_tc_hotel FOREIGN KEY (id_hotel)
        REFERENCES hotel (id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- SAISON (id_hotel ajouté par rapport au MCD)
CREATE TABLE IF NOT EXISTS saison (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_hotel    INT UNSIGNED NOT NULL,
    libelle     VARCHAR(100) NOT NULL,
    date_debut  DATE NOT NULL,
    date_fin    DATE NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_saison_hotel_libelle (id_hotel, libelle),
    UNIQUE KEY uq_saison_id_hotel (id, id_hotel),
    CONSTRAINT ck_saison_dates CHECK (date_fin >= date_debut),
    CONSTRAINT fk_saison_hotel FOREIGN KEY (id_hotel)
        REFERENCES hotel (id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- TARIF
CREATE TABLE IF NOT EXISTS tarif (
    id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_type_chambre  INT UNSIGNED NOT NULL,
    id_saison        INT UNSIGNED NOT NULL,
    prix_nuitee      DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_tarif_chambre_saison (id_type_chambre, id_saison),
    CONSTRAINT ck_tarif_prix CHECK (prix_nuitee >= 0),
    CONSTRAINT fk_tarif_type_chambre FOREIGN KEY (id_type_chambre)
        REFERENCES type_chambre (id) ON DELETE CASCADE,
    CONSTRAINT fk_tarif_saison FOREIGN KEY (id_saison)
        REFERENCES saison (id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- SUPPLEMENT_PENSION
CREATE TABLE IF NOT EXISTS supplement_pension (
    id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_hotel         INT UNSIGNED NOT NULL,
    type_pension     VARCHAR(50) NOT NULL,
    prix_supplement  DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_sp_hotel_type (id_hotel, type_pension),
    UNIQUE KEY uq_sp_id_hotel (id, id_hotel),
    CONSTRAINT ck_sp_prix CHECK (prix_supplement >= 0),
    CONSTRAINT fk_sp_hotel FOREIGN KEY (id_hotel)
        REFERENCES hotel (id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- COTATION (id_supplement_pension ajouté par rapport au MCD)
CREATE TABLE IF NOT EXISTS cotation (
    id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_hotel               INT UNSIGNED NOT NULL,
    id_type_chambre        INT UNSIGNED NOT NULL,
    id_saison              INT UNSIGNED NOT NULL,
    id_supplement_pension  INT UNSIGNED NULL,
    nombre_nuits           SMALLINT UNSIGNED NOT NULL,
    total_calcule          DECIMAL(14,2) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT ck_cot_nuits CHECK (nombre_nuits > 0),
    CONSTRAINT ck_cot_total CHECK (total_calcule >= 0),
    CONSTRAINT fk_cot_hotel FOREIGN KEY (id_hotel)
        REFERENCES hotel (id),
    CONSTRAINT fk_cot_type_chambre FOREIGN KEY (id_type_chambre, id_hotel)
        REFERENCES type_chambre (id, id_hotel),
    CONSTRAINT fk_cot_saison FOREIGN KEY (id_saison, id_hotel)
        REFERENCES saison (id, id_hotel),
    CONSTRAINT fk_cot_supplement FOREIGN KEY (id_supplement_pension, id_hotel)
        REFERENCES supplement_pension (id, id_hotel)
) ENGINE=InnoDB;
