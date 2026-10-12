-- Honey Group - Base Hôtels : jeu de données de test réaliste
-- Noms, contacts et prix INVENTÉS. Relançable sans erreur.
USE honey_hotels;

-- Nettoyage des anciennes données de test
DELETE FROM cotation;
DELETE FROM hotel WHERE remarques LIKE 'Données d%';

-- Équipements disponibles
INSERT IGNORE INTO equipement (libelle) VALUES
    ('Vue panoramique'), ('Piscine'), ('Wi-Fi'), ('Climatisation'),
    ('Restaurant'), ('Spa'), ('Parking'), ('Plage privée');

-- Hôtels de départ (base = prix d'une chambre double en haute saison, en Ariary)
CREATE TEMPORARY TABLE tmp_hotel (
    nom VARCHAR(150), localisation VARCHAR(150), categorie VARCHAR(50),
    contact VARCHAR(150), remarques TEXT, base INT
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO tmp_hotel VALUES
 ('Le Palmier Doré', 'Nosy Be', '4 étoiles', '+261 32 00 000 01', 'Données de test. Bungalows face à la mer.', 320000),
 ('Baobab Lodge', 'Morondava', '3 étoiles', '+261 32 00 000 02', 'Données de test. Proche de l''allée des baobabs.', 180000),
 ('Hôtel Rova', 'Antananarivo', '4 étoiles', '+261 32 00 000 03', 'Données de test. Centre-ville.', 260000),
 ('Les Hauts de l''Ikopa', 'Antsirabe', '3 étoiles', '+261 32 00 000 04', 'Données de test. Hôtel de ville thermale.', 150000),
 ('Ravinala Beach Resort', 'Sainte-Marie', '4 étoiles', '+261 32 00 000 05', 'Données de test. Plage et lagon.', 300000),
 ('Le Nid du Lémurien', 'Andasibe', '2 étoiles', '+261 32 00 000 06', 'Données de test. Proche de la réserve.', 90000),
 ('Panorama Isalo Lodge', 'Isalo', '3 étoiles', '+261 32 00 000 07', 'Données de test. Vue sur le massif.', 210000),
 ('Auberge du Tsingy', 'Bekopaka', '2 étoiles', '+261 32 00 000 08', 'Données de test. Accès aux Tsingy.', 120000),
 ('Hôtel de la Baie', 'Taolagnaro', '3 étoiles', '+261 32 00 000 09', 'Données de test. Vue sur la baie.', 200000);

INSERT INTO hotel (nom, localisation, categorie, contact, remarques)
SELECT nom, localisation, categorie, contact, remarques FROM tmp_hotel;

-- 3 types de chambre pour chaque hôtel
INSERT INTO type_chambre (id_hotel, libelle, capacite)
SELECT h.id, v.libelle, v.cap
FROM tmp_hotel p
JOIN hotel h ON h.nom = p.nom
CROSS JOIN (SELECT 'Chambre simple' AS libelle, 1 AS cap
            UNION ALL SELECT 'Chambre double', 2
            UNION ALL SELECT 'Suite familiale', 4) v;

-- 2 saisons pour chaque hôtel
INSERT INTO saison (id_hotel, libelle, date_debut, date_fin)
SELECT h.id, v.libelle, v.debut, v.fin
FROM tmp_hotel p
JOIN hotel h ON h.nom = p.nom
CROSS JOIN (SELECT 'Haute saison' AS libelle, DATE '2026-07-01' AS debut, DATE '2026-10-31' AS fin
            UNION ALL SELECT 'Basse saison', DATE '2026-11-01', DATE '2027-06-30') v;

-- Tarifs : base x coefficient de chambre x coefficient de saison
INSERT INTO tarif (id_type_chambre, id_saison, prix_nuitee)
SELECT tc.id, s.id,
       ROUND(p.base
             * CASE tc.libelle WHEN 'Chambre simple' THEN 0.7
                               WHEN 'Chambre double' THEN 1
                               ELSE 1.6 END
             * CASE s.libelle WHEN 'Haute saison' THEN 1 ELSE 0.75 END, -3)
FROM tmp_hotel p
JOIN hotel h ON h.nom = p.nom
JOIN type_chambre tc ON tc.id_hotel = h.id
JOIN saison s ON s.id_hotel = h.id;

-- Suppléments de pension (par nuit)
INSERT INTO supplement_pension (id_hotel, type_pension, prix_supplement)
SELECT h.id, v.type_pension, ROUND(p.base * v.coef, -3)
FROM tmp_hotel p
JOIN hotel h ON h.nom = p.nom
CROSS JOIN (SELECT 'Petit-déjeuner' AS type_pension, 0.08 AS coef
            UNION ALL SELECT 'Demi-pension', 0.22
            UNION ALL SELECT 'Pension complète', 0.35) v;

-- Équipements par hôtel
CREATE TEMPORARY TABLE tmp_equip (
    hotel VARCHAR(150), equip VARCHAR(100)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO tmp_equip VALUES
 ('Le Palmier Doré','Vue panoramique'), ('Le Palmier Doré','Piscine'), ('Le Palmier Doré','Spa'),
 ('Le Palmier Doré','Wi-Fi'), ('Le Palmier Doré','Restaurant'), ('Le Palmier Doré','Climatisation'),
 ('Le Palmier Doré','Plage privée'),
 ('Baobab Lodge','Piscine'), ('Baobab Lodge','Restaurant'), ('Baobab Lodge','Wi-Fi'), ('Baobab Lodge','Parking'),
 ('Hôtel Rova','Wi-Fi'), ('Hôtel Rova','Restaurant'), ('Hôtel Rova','Climatisation'),
 ('Hôtel Rova','Parking'), ('Hôtel Rova','Spa'),
 ('Les Hauts de l''Ikopa','Wi-Fi'), ('Les Hauts de l''Ikopa','Restaurant'), ('Les Hauts de l''Ikopa','Parking'),
 ('Ravinala Beach Resort','Vue panoramique'), ('Ravinala Beach Resort','Piscine'),
 ('Ravinala Beach Resort','Restaurant'), ('Ravinala Beach Resort','Wi-Fi'), ('Ravinala Beach Resort','Plage privée'),
 ('Le Nid du Lémurien','Restaurant'), ('Le Nid du Lémurien','Parking'),
 ('Panorama Isalo Lodge','Vue panoramique'), ('Panorama Isalo Lodge','Piscine'), ('Panorama Isalo Lodge','Restaurant'),
 ('Auberge du Tsingy','Restaurant'), ('Auberge du Tsingy','Wi-Fi'),
 ('Hôtel de la Baie','Vue panoramique'), ('Hôtel de la Baie','Piscine'),
 ('Hôtel de la Baie','Wi-Fi'), ('Hôtel de la Baie','Climatisation');

INSERT IGNORE INTO hotel_equipement (id_hotel, id_equipement)
SELECT h.id, e.id
FROM tmp_equip t
JOIN hotel h ON h.nom = t.hotel
JOIN equipement e ON e.libelle = t.equip;

-- 3 cotations d'exemple : total = nuits x (prix nuitée + supplément pension)
INSERT INTO cotation
    (id_hotel, id_type_chambre, id_saison, id_supplement_pension, nombre_nuits, total_calcule)
SELECT h.id, tc.id, s.id, sp.id, c.nuits, c.nuits * (t.prix_nuitee + sp.prix_supplement)
FROM (SELECT 'Le Palmier Doré' AS hotel, 'Chambre double' AS chambre,
             'Haute saison' AS saison, 'Demi-pension' AS pension, 4 AS nuits
      UNION ALL SELECT 'Baobab Lodge', 'Chambre double', 'Basse saison', 'Petit-déjeuner', 3
      UNION ALL SELECT 'Panorama Isalo Lodge', 'Suite familiale', 'Haute saison', 'Demi-pension', 5) c
JOIN hotel h ON h.nom = c.hotel
JOIN type_chambre tc ON tc.id_hotel = h.id AND tc.libelle = c.chambre
JOIN saison s ON s.id_hotel = h.id AND s.libelle = c.saison
JOIN tarif t ON t.id_type_chambre = tc.id AND t.id_saison = s.id
JOIN supplement_pension sp ON sp.id_hotel = h.id AND sp.type_pension = c.pension;

DROP TEMPORARY TABLE tmp_equip;
DROP TEMPORARY TABLE tmp_hotel;
