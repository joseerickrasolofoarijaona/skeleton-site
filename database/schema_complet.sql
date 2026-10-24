-- Honey Group : structure complète des deux bases (indépendantes).
-- Générée depuis les bases testées. À lancer une seule fois : sudo mariadb < schema_complet.sql
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `equipement` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `libelle` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_equipement_libelle` (`libelle`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `hotel` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nom` varchar(150) NOT NULL,
  `localisation` varchar(150) NOT NULL,
  `categorie` varchar(50) DEFAULT NULL,
  `contact` varchar(150) DEFAULT NULL,
  `remarques` text DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1 CHECK (`actif` in (0,1)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_hotel_nom_localisation` (`nom`,`localisation`),
  KEY `idx_hotel_localisation` (`localisation`),
  KEY `idx_hotel_categorie` (`categorie`),
  KEY `idx_hotel_actif` (`actif`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_saison_hotel_libelle` (`id_hotel`,`libelle`),
  UNIQUE KEY `uq_saison_id_hotel` (`id`,`id_hotel`),
  CONSTRAINT `fk_saison_hotel` FOREIGN KEY (`id_hotel`) REFERENCES `hotel` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_saison_dates` CHECK (`date_fin` >= `date_debut`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `supplement_pension` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_hotel` int(10) unsigned NOT NULL,
  `type_pension` varchar(50) NOT NULL,
  `prix_supplement` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sp_hotel_type` (`id_hotel`,`type_pension`),
  UNIQUE KEY `uq_sp_id_hotel` (`id`,`id_hotel`),
  CONSTRAINT `fk_sp_hotel` FOREIGN KEY (`id_hotel`) REFERENCES `hotel` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_sp_prix` CHECK (`prix_supplement` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `tarif` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_type_chambre` int(10) unsigned NOT NULL,
  `id_saison` int(10) unsigned NOT NULL,
  `prix_nuitee` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tarif_chambre_saison` (`id_type_chambre`,`id_saison`),
  KEY `fk_tarif_saison` (`id_saison`),
  CONSTRAINT `fk_tarif_saison` FOREIGN KEY (`id_saison`) REFERENCES `saison` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tarif_type_chambre` FOREIGN KEY (`id_type_chambre`) REFERENCES `type_chambre` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_tarif_prix` CHECK (`prix_nuitee` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `type_chambre` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_hotel` int(10) unsigned NOT NULL,
  `libelle` varchar(100) NOT NULL,
  `capacite` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tc_hotel_libelle` (`id_hotel`,`libelle`),
  UNIQUE KEY `uq_tc_id_hotel` (`id`,`id_hotel`),
  CONSTRAINT `fk_tc_hotel` FOREIGN KEY (`id_hotel`) REFERENCES `hotel` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_tc_capacite` CHECK (`capacite` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `loueur` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nom` varchar(150) NOT NULL,
  `telephone` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `localisation` varchar(150) DEFAULT NULL,
  `remarques` text DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1 CHECK (`actif` in (0,1)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_loueur_nom` (`nom`),
  KEY `idx_loueur_actif` (`actif`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `saison_vehicule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_loueur` int(10) unsigned NOT NULL,
  `libelle` varchar(100) NOT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sv_loueur_libelle` (`id_loueur`,`libelle`),
  KEY `idx_sv_periode` (`date_debut`,`date_fin`),
  CONSTRAINT `fk_sv_loueur` FOREIGN KEY (`id_loueur`) REFERENCES `loueur` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_sv_dates` CHECK (`date_fin` >= `date_debut`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `tarif_vehicule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_vehicule` int(10) unsigned NOT NULL,
  `id_saison_vehicule` int(10) unsigned NOT NULL,
  `prix_journalier` decimal(12,2) NOT NULL,
  `inclus_chauffeur` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tv_vehicule_saison_chauffeur` (`id_vehicule`,`id_saison_vehicule`,`inclus_chauffeur`),
  KEY `fk_tv_saison` (`id_saison_vehicule`),
  CONSTRAINT `fk_tv_saison` FOREIGN KEY (`id_saison_vehicule`) REFERENCES `saison_vehicule` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tv_vehicule` FOREIGN KEY (`id_vehicule`) REFERENCES `vehicule` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_tv_prix` CHECK (`prix_journalier` >= 0),
  CONSTRAINT `ck_tv_chauffeur` CHECK (`inclus_chauffeur` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `vehicule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_loueur` int(10) unsigned NOT NULL,
  `modele` varchar(100) NOT NULL,
  `categorie` varchar(50) NOT NULL,
  `capacite_passagers` tinyint(3) unsigned NOT NULL,
  `climatisation` tinyint(1) NOT NULL DEFAULT 0,
  `remarques` text DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1 CHECK (`actif` in (0,1)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_vehicule_loueur_modele` (`id_loueur`,`modele`),
  KEY `idx_vehicule_categorie` (`categorie`),
  KEY `idx_vehicule_actif` (`actif`),
  CONSTRAINT `fk_vehicule_loueur` FOREIGN KEY (`id_loueur`) REFERENCES `loueur` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_vehicule_capacite` CHECK (`capacite_passagers` > 0),
  CONSTRAINT `ck_vehicule_clim` CHECK (`climatisation` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

