-- Honey Group : données de démonstration (noms, contacts et prix INVENTÉS).
-- À lancer après schema_complet.sql : sudo mariadb < donnees_demo.sql
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

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `cotation` DISABLE KEYS */;
INSERT INTO `cotation` (`id`, `id_hotel`, `id_type_chambre`, `id_saison`, `id_supplement_pension`, `nombre_nuits`, `total_calcule`) VALUES (6,14,32,22,32,4,1560000.00),
(7,15,35,25,34,3,447000.00),
(8,20,51,34,50,5,1910000.00);
/*!40000 ALTER TABLE `cotation` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `equipement` DISABLE KEYS */;
INSERT INTO `equipement` (`id`, `libelle`) VALUES (4,'Climatisation'),
(7,'Parking'),
(2,'Piscine'),
(8,'Plage privée'),
(5,'Restaurant'),
(6,'Spa'),
(1,'Vue panoramique'),
(3,'Wi-Fi');
/*!40000 ALTER TABLE `equipement` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `hotel` DISABLE KEYS */;
INSERT INTO `hotel` (`id`, `nom`, `localisation`, `categorie`, `contact`, `remarques`, `actif`) VALUES (14,'Le Palmier Doré','Nosy Be','4 étoiles','+261 32 00 000 01','Données de test. Bungalows face à la mer.',1),
(15,'Baobab Lodge','Morondava','3 étoiles','+261 32 00 000 02','Données de test. Proche de l\'allée des baobabs.',1),
(16,'Hôtel Rova','Antananarivo','4 étoiles','+261 32 00 000 03','Données de test. Centre-ville.',1),
(17,'Les Hauts de l\'Ikopa','Antsirabe','3 étoiles','+261 32 00 000 04','Données de test. Hôtel de ville thermale.',1),
(18,'Ravinala Beach Resort','Sainte-Marie','4 étoiles','+261 32 00 000 05','Données de test. Plage et lagon.',1),
(19,'Le Nid du Lémurien','Andasibe','2 étoiles','+261 32 00 000 06','Données de test. Proche de la réserve.',1),
(20,'Panorama Isalo Lodge','Isalo','3 étoiles','+261 32 00 000 07','Données de test. Vue sur le massif.',1),
(21,'Auberge du Tsingy','Bekopaka','2 étoiles','+261 32 00 000 08','Données de test. Accès aux Tsingy.',1),
(22,'Hôtel de la Baie','Taolagnaro','3 étoiles','+261 32 00 000 09','Données de test. Vue sur la baie.',1);
/*!40000 ALTER TABLE `hotel` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `hotel_equipement` DISABLE KEYS */;
INSERT INTO `hotel_equipement` (`id_hotel`, `id_equipement`) VALUES (14,1),
(18,1),
(20,1),
(22,1),
(14,2),
(15,2),
(18,2),
(20,2),
(22,2),
(14,3),
(15,3),
(16,3),
(17,3),
(18,3),
(21,3),
(22,3),
(14,4),
(16,4),
(22,4),
(14,5),
(15,5),
(16,5),
(17,5),
(18,5),
(19,5),
(20,5),
(21,5),
(14,6),
(16,6),
(15,7),
(16,7),
(17,7),
(19,7),
(14,8),
(18,8);
/*!40000 ALTER TABLE `hotel_equipement` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `saison` DISABLE KEYS */;
INSERT INTO `saison` (`id`, `id_hotel`, `libelle`, `date_debut`, `date_fin`) VALUES (22,14,'Haute saison','2026-07-01','2026-10-31'),
(23,14,'Basse saison','2026-11-01','2027-06-30'),
(24,15,'Haute saison','2026-07-01','2026-10-31'),
(25,15,'Basse saison','2026-11-01','2027-06-30'),
(26,16,'Haute saison','2026-07-01','2026-10-31'),
(27,16,'Basse saison','2026-11-01','2027-06-30'),
(28,17,'Haute saison','2026-07-01','2026-10-31'),
(29,17,'Basse saison','2026-11-01','2027-06-30'),
(30,18,'Haute saison','2026-07-01','2026-10-31'),
(31,18,'Basse saison','2026-11-01','2027-06-30'),
(32,19,'Haute saison','2026-07-01','2026-10-31'),
(33,19,'Basse saison','2026-11-01','2027-06-30'),
(34,20,'Haute saison','2026-07-01','2026-10-31'),
(35,20,'Basse saison','2026-11-01','2027-06-30'),
(36,21,'Haute saison','2026-07-01','2026-10-31'),
(37,21,'Basse saison','2026-11-01','2027-06-30'),
(38,22,'Haute saison','2026-07-01','2026-10-31'),
(39,22,'Basse saison','2026-11-01','2027-06-30');
/*!40000 ALTER TABLE `saison` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `supplement_pension` DISABLE KEYS */;
INSERT INTO `supplement_pension` (`id`, `id_hotel`, `type_pension`, `prix_supplement`) VALUES (31,14,'Petit-déjeuner',26000.00),
(32,14,'Demi-pension',70000.00),
(33,14,'Pension complète',112000.00),
(34,15,'Petit-déjeuner',14000.00),
(35,15,'Demi-pension',40000.00),
(36,15,'Pension complète',63000.00),
(37,16,'Petit-déjeuner',21000.00),
(38,16,'Demi-pension',57000.00),
(39,16,'Pension complète',91000.00),
(40,17,'Petit-déjeuner',12000.00),
(41,17,'Demi-pension',33000.00),
(42,17,'Pension complète',53000.00),
(43,18,'Petit-déjeuner',24000.00),
(44,18,'Demi-pension',66000.00),
(45,18,'Pension complète',105000.00),
(46,19,'Petit-déjeuner',7000.00),
(47,19,'Demi-pension',20000.00),
(48,19,'Pension complète',32000.00),
(49,20,'Petit-déjeuner',17000.00),
(50,20,'Demi-pension',46000.00),
(51,20,'Pension complète',74000.00),
(52,21,'Petit-déjeuner',10000.00),
(53,21,'Demi-pension',26000.00),
(54,21,'Pension complète',42000.00),
(55,22,'Petit-déjeuner',16000.00),
(56,22,'Demi-pension',44000.00),
(57,22,'Pension complète',70000.00);
/*!40000 ALTER TABLE `supplement_pension` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `tarif` DISABLE KEYS */;
INSERT INTO `tarif` (`id`, `id_type_chambre`, `id_saison`, `prix_nuitee`) VALUES (60,32,23,240000.00),
(61,31,23,168000.00),
(62,33,23,384000.00),
(63,32,22,320000.00),
(64,31,22,224000.00),
(65,33,22,512000.00),
(66,35,25,135000.00),
(67,34,25,95000.00),
(68,36,25,216000.00),
(69,35,24,180000.00),
(70,34,24,126000.00),
(71,36,24,288000.00),
(72,38,27,195000.00),
(73,37,27,137000.00),
(74,39,27,312000.00),
(75,38,26,260000.00),
(76,37,26,182000.00),
(77,39,26,416000.00),
(78,41,29,113000.00),
(79,40,29,79000.00),
(80,42,29,180000.00),
(81,41,28,150000.00),
(82,40,28,105000.00),
(83,42,28,240000.00),
(84,44,31,225000.00),
(85,43,31,158000.00),
(86,45,31,360000.00),
(87,44,30,300000.00),
(88,43,30,210000.00),
(89,45,30,480000.00),
(90,47,33,68000.00),
(91,46,33,47000.00),
(92,48,33,108000.00),
(93,47,32,90000.00),
(94,46,32,63000.00),
(95,48,32,144000.00),
(96,50,35,158000.00),
(97,49,35,110000.00),
(98,51,35,252000.00),
(99,50,34,210000.00),
(100,49,34,147000.00),
(101,51,34,336000.00),
(102,53,37,90000.00),
(103,52,37,63000.00),
(104,54,37,144000.00),
(105,53,36,120000.00),
(106,52,36,84000.00),
(107,54,36,192000.00),
(108,56,39,150000.00),
(109,55,39,105000.00),
(110,57,39,240000.00),
(111,56,38,200000.00),
(112,55,38,140000.00),
(113,57,38,320000.00);
/*!40000 ALTER TABLE `tarif` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `type_chambre` DISABLE KEYS */;
INSERT INTO `type_chambre` (`id`, `id_hotel`, `libelle`, `capacite`, `nb_chambres`) VALUES (31,14,'Chambre simple',1,5),
(32,14,'Chambre double',2,5),
(33,14,'Suite familiale',4,5),
(34,15,'Chambre simple',1,5),
(35,15,'Chambre double',2,5),
(36,15,'Suite familiale',4,5),
(37,16,'Chambre simple',1,5),
(38,16,'Chambre double',2,5),
(39,16,'Suite familiale',4,5),
(40,17,'Chambre simple',1,5),
(41,17,'Chambre double',2,5),
(42,17,'Suite familiale',4,5),
(43,18,'Chambre simple',1,5),
(44,18,'Chambre double',2,5),
(45,18,'Suite familiale',4,5),
(46,19,'Chambre simple',1,5),
(47,19,'Chambre double',2,5),
(48,19,'Suite familiale',4,5),
(49,20,'Chambre simple',1,5),
(50,20,'Chambre double',2,5),
(51,20,'Suite familiale',4,5),
(52,21,'Chambre simple',1,5),
(53,21,'Chambre double',2,5),
(54,21,'Suite familiale',4,5),
(55,22,'Chambre simple',1,5),
(56,22,'Chambre double',2,5),
(57,22,'Suite familiale',4,5);
/*!40000 ALTER TABLE `type_chambre` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

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

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `cotation_vehicule` DISABLE KEYS */;
INSERT INTO `cotation_vehicule` (`id`, `id_vehicule`, `id_saison_vehicule`, `inclus_chauffeur`, `nombre_jours`, `nombre_vehicules`, `total_calcule`) VALUES (6,15,12,1,5,1,1750000.00),
(7,18,15,0,3,2,960000.00),
(8,23,18,1,2,1,1000000.00);
/*!40000 ALTER TABLE `cotation_vehicule` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `loueur` DISABLE KEYS */;
INSERT INTO `loueur` (`id`, `nom`, `telephone`, `email`, `localisation`, `remarques`, `actif`) VALUES (8,'Mada 4x4 Location','+261 34 00 000 01','contact@mada4x4.example','Antananarivo','Données de test. Spécialiste des 4x4 et minibus.',1),
(9,'Nosy Be Transports','+261 34 00 000 02','info@nosybe-transports.example','Nosy Be','Données de test. Transferts et locations sur l\'île.',1),
(10,'Morondava Aventures','+261 34 00 000 03','resa@morondava-aventures.example','Morondava','Données de test. Pistes de l\'Ouest.',1),
(11,'Hauts-Plateaux Car','+261 34 00 000 04','contact@hauts-plateaux-car.example','Antsirabe','Données de test. Autocars et berlines.',1);
/*!40000 ALTER TABLE `loueur` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `saison_vehicule` DISABLE KEYS */;
INSERT INTO `saison_vehicule` (`id`, `id_loueur`, `libelle`, `date_debut`, `date_fin`) VALUES (12,8,'Haute saison','2026-07-01','2026-10-31'),
(13,8,'Basse saison','2026-11-01','2027-06-30'),
(14,9,'Haute saison','2026-07-01','2026-10-31'),
(15,9,'Basse saison','2026-11-01','2027-06-30'),
(16,10,'Haute saison','2026-07-01','2026-10-31'),
(17,10,'Basse saison','2026-11-01','2027-06-30'),
(18,11,'Haute saison','2026-07-01','2026-10-31'),
(19,11,'Basse saison','2026-11-01','2027-06-30');
/*!40000 ALTER TABLE `saison_vehicule` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `tarif_vehicule` DISABLE KEYS */;
INSERT INTO `tarif_vehicule` (`id`, `id_vehicule`, `id_saison_vehicule`, `prix_journalier`, `inclus_chauffeur`) VALUES (46,15,13,280000.00,1),
(47,15,12,350000.00,1),
(48,15,13,224000.00,0),
(49,15,12,280000.00,0),
(50,16,13,240000.00,1),
(51,16,12,300000.00,1),
(52,16,13,192000.00,0),
(53,16,12,240000.00,0),
(54,17,13,320000.00,1),
(55,17,12,400000.00,1),
(56,17,13,256000.00,0),
(57,17,12,320000.00,0),
(58,18,15,200000.00,1),
(59,18,14,250000.00,1),
(60,18,15,160000.00,0),
(61,18,14,200000.00,0),
(62,19,15,160000.00,1),
(63,19,14,200000.00,1),
(64,19,15,128000.00,0),
(65,19,14,160000.00,0),
(66,20,15,96000.00,1),
(67,20,14,120000.00,1),
(68,20,15,77000.00,0),
(69,20,14,96000.00,0),
(70,21,17,264000.00,1),
(71,21,16,330000.00,1),
(72,21,17,211000.00,0),
(73,21,16,264000.00,0),
(74,22,17,224000.00,1),
(75,22,16,280000.00,1),
(76,22,17,179000.00,0),
(77,22,16,224000.00,0),
(78,23,19,400000.00,1),
(79,23,18,500000.00,1),
(80,23,19,320000.00,0),
(81,23,18,400000.00,0),
(82,24,19,144000.00,1),
(83,24,18,180000.00,1),
(84,24,19,115000.00,0),
(85,24,18,144000.00,0);
/*!40000 ALTER TABLE `tarif_vehicule` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
/*!40000 ALTER TABLE `vehicule` DISABLE KEYS */;
INSERT INTO `vehicule` (`id`, `id_loueur`, `modele`, `categorie`, `capacite_passagers`, `nb_exemplaires`, `climatisation`, `remarques`, `actif`) VALUES (15,8,'Toyota Land Cruiser','4x4',7,3,1,NULL,1),
(16,8,'Toyota Hilux','4x4',5,3,1,NULL,1),
(17,8,'Toyota HiAce','Minibus',15,3,1,NULL,1),
(18,9,'Hyundai Starex','Minibus',9,3,1,NULL,1),
(19,9,'Suzuki Jimny','4x4',4,3,1,NULL,1),
(20,9,'Dacia Logan','Berline',4,3,1,NULL,1),
(21,10,'Toyota Land Cruiser','4x4',7,3,1,NULL,1),
(22,10,'Mitsubishi L200','4x4',5,3,0,NULL,1),
(23,11,'Toyota Coaster','Minibus',25,3,1,NULL,1),
(24,11,'Peugeot 508','Berline',4,3,1,NULL,1);
/*!40000 ALTER TABLE `vehicule` ENABLE KEYS */;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

