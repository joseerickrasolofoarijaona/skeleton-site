-- Honey Group : structure complète des deux bases (indépendantes).
-- Générée depuis les bases testées. Ordre d'installation :
--   schema_complet.sql, donnees_reference.sql, donnees_demo.sql (facultatif), utilisateur.sql
CREATE DATABASE IF NOT EXISTS honey_hotels CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE honey_hotels;
/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `categorie_hotel` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `libelle` varchar(50) NOT NULL,
  `ordre` smallint(5) unsigned NOT NULL DEFAULT 99,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_categorie_hotel_libelle` (`libelle`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `cotation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_hotel` int(10) unsigned NOT NULL,
  `id_type_chambre` int(10) unsigned NOT NULL,
  `id_saison` int(10) unsigned NOT NULL,
  `id_supplement_pension` int(10) unsigned DEFAULT NULL,
  `nombre_nuits` smallint(5) unsigned NOT NULL,
  `total_calcule` decimal(14,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cot_hotel` (`id_hotel`),
  KEY `fk_cot_type_chambre` (`id_type_chambre`,`id_hotel`),
  KEY `fk_cot_saison` (`id_saison`,`id_hotel`),
  KEY `fk_cot_supplement` (`id_supplement_pension`,`id_hotel`),
  CONSTRAINT `fk_cot_hotel` FOREIGN KEY (`id_hotel`) REFERENCES `hotel` (`id`),
  CONSTRAINT `fk_cot_saison` FOREIGN KEY (`id_saison`, `id_hotel`) REFERENCES `saison` (`id`, `id_hotel`),
  CONSTRAINT `fk_cot_supplement` FOREIGN KEY (`id_supplement_pension`, `id_hotel`) REFERENCES `supplement_pension` (`id`, `id_hotel`),
  CONSTRAINT `fk_cot_type_chambre` FOREIGN KEY (`id_type_chambre`, `id_hotel`) REFERENCES `type_chambre` (`id`, `id_hotel`),
  CONSTRAINT `ck_cot_nuits` CHECK (`nombre_nuits` > 0),
  CONSTRAINT `ck_cot_total` CHECK (`total_calcule` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `destination` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nom` varchar(150) NOT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_destination_nom` (`nom`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `equipement` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `libelle` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_equipement_libelle` (`libelle`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `hotel` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code_externe` varchar(40) DEFAULT NULL COMMENT 'Code de l''hôtel dans le système de cotation existant',
  `nom` varchar(150) NOT NULL,
  `localisation` varchar(150) NOT NULL,
  `categorie` varchar(50) DEFAULT NULL,
  `contact` varchar(150) DEFAULT NULL,
  `remarques` text DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1 CHECK (`actif` in (0,1)),
  `cree_le` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Création de la ligne',
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Dernière modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_hotel_nom_localisation` (`nom`,`localisation`),
  UNIQUE KEY `uq_hotel_code_externe` (`code_externe`),
  KEY `idx_hotel_localisation` (`localisation`),
  KEY `idx_hotel_categorie` (`categorie`),
  KEY `idx_hotel_actif` (`actif`),
  CONSTRAINT `fk_hotel_categorie` FOREIGN KEY (`categorie`) REFERENCES `categorie_hotel` (`libelle`) ON UPDATE CASCADE,
  CONSTRAINT `fk_hotel_destination` FOREIGN KEY (`localisation`) REFERENCES `destination` (`nom`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `hotel_equipement` (
  `id_hotel` int(10) unsigned NOT NULL,
  `id_equipement` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id_hotel`,`id_equipement`),
  KEY `fk_he_equipement` (`id_equipement`),
  CONSTRAINT `fk_he_equipement` FOREIGN KEY (`id_equipement`) REFERENCES `equipement` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_he_hotel` FOREIGN KEY (`id_hotel`) REFERENCES `hotel` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `saison` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_hotel` int(10) unsigned NOT NULL,
  `libelle` varchar(100) NOT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date NOT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Création de la ligne',
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Dernière modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_saison_hotel_libelle` (`id_hotel`,`libelle`),
  UNIQUE KEY `uq_saison_id_hotel` (`id`,`id_hotel`),
  CONSTRAINT `fk_saison_hotel` FOREIGN KEY (`id_hotel`) REFERENCES `hotel` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_saison_dates` CHECK (`date_fin` >= `date_debut`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `supplement_pension` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_hotel` int(10) unsigned NOT NULL,
  `type_pension` varchar(50) NOT NULL,
  `prix_supplement` decimal(12,2) NOT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Création de la ligne',
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Dernière modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sp_hotel_type` (`id_hotel`,`type_pension`),
  UNIQUE KEY `uq_sp_id_hotel` (`id`,`id_hotel`),
  CONSTRAINT `fk_sp_hotel` FOREIGN KEY (`id_hotel`) REFERENCES `hotel` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_sp_prix` CHECK (`prix_supplement` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `tarif` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_type_chambre` int(10) unsigned NOT NULL,
  `id_saison` int(10) unsigned NOT NULL,
  `prix_nuitee` decimal(12,2) NOT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Création de la ligne',
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Dernière modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tarif_chambre_saison` (`id_type_chambre`,`id_saison`),
  KEY `fk_tarif_saison` (`id_saison`),
  CONSTRAINT `fk_tarif_saison` FOREIGN KEY (`id_saison`) REFERENCES `saison` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tarif_type_chambre` FOREIGN KEY (`id_type_chambre`) REFERENCES `type_chambre` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_tarif_prix` CHECK (`prix_nuitee` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `type_chambre` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_hotel` int(10) unsigned NOT NULL,
  `code_externe` varchar(40) DEFAULT NULL COMMENT 'Code du type de chambre dans le système de cotation existant',
  `libelle` varchar(100) NOT NULL,
  `capacite` tinyint(3) unsigned NOT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Création de la ligne',
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Dernière modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tc_hotel_libelle` (`id_hotel`,`libelle`),
  UNIQUE KEY `uq_tc_id_hotel` (`id`,`id_hotel`),
  UNIQUE KEY `uq_tc_code_externe` (`id_hotel`,`code_externe`),
  CONSTRAINT `fk_tc_hotel` FOREIGN KEY (`id_hotel`) REFERENCES `hotel` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_tc_capacite` CHECK (`capacite` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

CREATE DATABASE IF NOT EXISTS honey_vehicules CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE honey_vehicules;
/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `cotation_vehicule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_vehicule` int(10) unsigned NOT NULL,
  `id_saison_vehicule` int(10) unsigned NOT NULL,
  `inclus_chauffeur` tinyint(1) NOT NULL DEFAULT 0,
  `nombre_jours` smallint(5) unsigned NOT NULL,
  `nombre_vehicules` smallint(5) unsigned NOT NULL DEFAULT 1,
  `total_calcule` decimal(14,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cv_tarif` (`id_vehicule`,`id_saison_vehicule`,`inclus_chauffeur`),
  CONSTRAINT `fk_cv_tarif` FOREIGN KEY (`id_vehicule`, `id_saison_vehicule`, `inclus_chauffeur`) REFERENCES `tarif_vehicule` (`id_vehicule`, `id_saison_vehicule`, `inclus_chauffeur`),
  CONSTRAINT `ck_cv_jours` CHECK (`nombre_jours` > 0),
  CONSTRAINT `ck_cv_vehicules` CHECK (`nombre_vehicules` > 0),
  CONSTRAINT `ck_cv_total` CHECK (`total_calcule` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `loueur` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code_externe` varchar(40) DEFAULT NULL COMMENT 'Code du loueur dans le système de cotation existant',
  `nom` varchar(150) NOT NULL,
  `telephone` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `localisation` varchar(150) DEFAULT NULL,
  `remarques` text DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1 CHECK (`actif` in (0,1)),
  `cree_le` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Création de la ligne',
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Dernière modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_loueur_nom` (`nom`),
  UNIQUE KEY `uq_loueur_code_externe` (`code_externe`),
  KEY `idx_loueur_actif` (`actif`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `saison_vehicule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_loueur` int(10) unsigned NOT NULL,
  `libelle` varchar(100) NOT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date NOT NULL,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Création de la ligne',
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Dernière modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sv_loueur_libelle` (`id_loueur`,`libelle`),
  KEY `idx_sv_periode` (`date_debut`,`date_fin`),
  CONSTRAINT `fk_sv_loueur` FOREIGN KEY (`id_loueur`) REFERENCES `loueur` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_sv_dates` CHECK (`date_fin` >= `date_debut`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `tarif_vehicule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_vehicule` int(10) unsigned NOT NULL,
  `id_saison_vehicule` int(10) unsigned NOT NULL,
  `prix_journalier` decimal(12,2) NOT NULL,
  `inclus_chauffeur` tinyint(1) NOT NULL DEFAULT 0,
  `cree_le` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Création de la ligne',
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Dernière modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tv_vehicule_saison_chauffeur` (`id_vehicule`,`id_saison_vehicule`,`inclus_chauffeur`),
  KEY `fk_tv_saison` (`id_saison_vehicule`),
  CONSTRAINT `fk_tv_saison` FOREIGN KEY (`id_saison_vehicule`) REFERENCES `saison_vehicule` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tv_vehicule` FOREIGN KEY (`id_vehicule`) REFERENCES `vehicule` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_tv_prix` CHECK (`prix_journalier` >= 0),
  CONSTRAINT `ck_tv_chauffeur` CHECK (`inclus_chauffeur` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `type_vehicule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `libelle` varchar(50) NOT NULL,
  `ordre` smallint(5) unsigned NOT NULL DEFAULT 99,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_type_vehicule_libelle` (`libelle`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `vehicule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_loueur` int(10) unsigned NOT NULL,
  `code_externe` varchar(40) DEFAULT NULL COMMENT 'Code du véhicule dans le système de cotation existant',
  `modele` varchar(100) NOT NULL,
  `categorie` varchar(50) NOT NULL,
  `capacite_passagers` tinyint(3) unsigned NOT NULL,
  `climatisation` tinyint(1) NOT NULL DEFAULT 0,
  `remarques` text DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1 CHECK (`actif` in (0,1)),
  `cree_le` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Création de la ligne',
  `modifie_le` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Dernière modification',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_vehicule_loueur_modele` (`id_loueur`,`modele`),
  UNIQUE KEY `uq_vehicule_code_externe` (`code_externe`),
  KEY `idx_vehicule_categorie` (`categorie`),
  KEY `idx_vehicule_actif` (`actif`),
  CONSTRAINT `fk_vehicule_loueur` FOREIGN KEY (`id_loueur`) REFERENCES `loueur` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vehicule_type` FOREIGN KEY (`categorie`) REFERENCES `type_vehicule` (`libelle`) ON UPDATE CASCADE,
  CONSTRAINT `ck_vehicule_capacite` CHECK (`capacite_passagers` > 0),
  CONSTRAINT `ck_vehicule_clim` CHECK (`climatisation` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Vues de lecture pour le système de cotation (montants en Ariary, MGA).

USE honey_hotels;

CREATE OR REPLACE VIEW v_tarifs_hotel AS
SELECT
    h.id                                AS hotel_id,
    CONCAT('HOT-', LPAD(h.id, 5, '0'))  AS hotel_code,
    h.code_externe                      AS hotel_code_externe,
    h.nom                               AS hotel_nom,
    h.localisation                      AS destination,
    h.categorie                         AS categorie,
    h.actif                             AS hotel_actif,
    tc.id                               AS type_chambre_id,
    tc.code_externe                     AS type_chambre_code_externe,
    tc.libelle                          AS type_chambre,
    tc.capacite                         AS capacite,
    s.id                                AS saison_id,
    s.libelle                           AS saison,
    s.date_debut                        AS saison_debut,
    s.date_fin                          AS saison_fin,
    t.prix_nuitee                       AS prix_nuitee_mga,
    t.modifie_le                        AS tarif_modifie_le
FROM hotel h
JOIN type_chambre tc ON tc.id_hotel = h.id
JOIN tarif t         ON t.id_type_chambre = tc.id
JOIN saison s        ON s.id = t.id_saison AND s.id_hotel = h.id;

CREATE OR REPLACE VIEW v_supplements_hotel AS
SELECT
    h.id                                AS hotel_id,
    CONCAT('HOT-', LPAD(h.id, 5, '0'))  AS hotel_code,
    h.code_externe                      AS hotel_code_externe,
    h.nom                               AS hotel_nom,
    h.actif                             AS hotel_actif,
    sp.id                               AS supplement_id,
    sp.type_pension                     AS type_pension,
    sp.prix_supplement                  AS prix_supplement_mga,
    sp.modifie_le                       AS supplement_modifie_le
FROM hotel h
JOIN supplement_pension sp ON sp.id_hotel = h.id;

CREATE OR REPLACE VIEW v_equipements_hotel AS
SELECT
    h.id                                AS hotel_id,
    CONCAT('HOT-', LPAD(h.id, 5, '0'))  AS hotel_code,
    h.nom                               AS hotel_nom,
    e.libelle                           AS equipement
FROM hotel h
JOIN hotel_equipement he ON he.id_hotel = h.id
JOIN equipement e        ON e.id = he.id_equipement;



USE honey_vehicules;

CREATE OR REPLACE VIEW v_tarifs_vehicule AS
SELECT
    l.id                                AS loueur_id,
    CONCAT('LOU-', LPAD(l.id, 5, '0'))  AS loueur_code,
    l.code_externe                      AS loueur_code_externe,
    l.nom                               AS loueur_nom,
    l.localisation                      AS loueur_ville,
    l.actif                             AS loueur_actif,
    v.id                                AS vehicule_id,
    CONCAT('VEH-', LPAD(v.id, 5, '0'))  AS vehicule_code,
    v.code_externe                      AS vehicule_code_externe,
    v.modele                            AS modele,
    v.categorie                         AS type_vehicule,
    v.capacite_passagers                AS capacite_passagers,
    v.climatisation                     AS climatisation,
    v.actif                             AS vehicule_actif,
    sv.id                               AS saison_id,
    sv.libelle                          AS saison,
    sv.date_debut                       AS saison_debut,
    sv.date_fin                         AS saison_fin,
    tv.inclus_chauffeur                 AS inclus_chauffeur,
    tv.prix_journalier                  AS prix_journalier_mga,
    tv.modifie_le                       AS tarif_modifie_le
FROM loueur l
JOIN vehicule v          ON v.id_loueur = l.id
JOIN tarif_vehicule tv   ON tv.id_vehicule = v.id
JOIN saison_vehicule sv  ON sv.id = tv.id_saison_vehicule AND sv.id_loueur = l.id;
