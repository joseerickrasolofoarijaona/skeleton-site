-- Honey Group - Base Véhicules : jeu de données de test réaliste
-- Noms, contacts et prix INVENTÉS. Relançable sans erreur.
USE honey_vehicules;

-- Nettoyage des anciennes données de test
DELETE FROM cotation_vehicule;
DELETE FROM loueur WHERE remarques LIKE 'Données d%';

-- Loueurs
CREATE TEMPORARY TABLE tmp_loueur (
    nom VARCHAR(150), telephone VARCHAR(50), email VARCHAR(150),
    localisation VARCHAR(150), remarques TEXT
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO tmp_loueur VALUES
 ('Mada 4x4 Location', '+261 34 00 000 01', 'contact@mada4x4.example', 'Antananarivo', 'Données de test. Spécialiste des 4x4 et minibus.'),
 ('Nosy Be Transports', '+261 34 00 000 02', 'info@nosybe-transports.example', 'Nosy Be', 'Données de test. Transferts et locations sur l''île.'),
 ('Morondava Aventures', '+261 34 00 000 03', 'resa@morondava-aventures.example', 'Morondava', 'Données de test. Pistes de l''Ouest.'),
 ('Hauts-Plateaux Car', '+261 34 00 000 04', 'contact@hauts-plateaux-car.example', 'Antsirabe', 'Données de test. Autocars et berlines.');

INSERT INTO loueur (nom, telephone, email, localisation, remarques)
SELECT nom, telephone, email, localisation, remarques FROM tmp_loueur;

-- Véhicules (base = prix journalier AVEC chauffeur, en haute saison, en Ariary)
CREATE TEMPORARY TABLE tmp_veh (
    loueur VARCHAR(150), modele VARCHAR(100), categorie VARCHAR(50),
    cap INT, clim INT, base INT
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO tmp_veh VALUES
 ('Mada 4x4 Location', 'Toyota Land Cruiser', '4x4', 7, 1, 350000),
 ('Mada 4x4 Location', 'Toyota Hilux', '4x4', 5, 1, 300000),
 ('Mada 4x4 Location', 'Toyota HiAce', 'Minibus', 15, 1, 400000),
 ('Nosy Be Transports', 'Hyundai Starex', 'Minibus', 9, 1, 250000),
 ('Nosy Be Transports', 'Suzuki Jimny', '4x4', 4, 1, 200000),
 ('Nosy Be Transports', 'Dacia Logan', 'Berline', 4, 1, 120000),
 ('Morondava Aventures', 'Toyota Land Cruiser', '4x4', 7, 1, 330000),
 ('Morondava Aventures', 'Mitsubishi L200', '4x4', 5, 0, 280000),
 ('Hauts-Plateaux Car', 'Toyota Coaster', 'Minibus', 25, 1, 500000),
 ('Hauts-Plateaux Car', 'Peugeot 508', 'Berline', 4, 1, 180000);

INSERT INTO vehicule (id_loueur, modele, categorie, capacite_passagers, climatisation)
SELECT l.id, t.modele, t.categorie, t.cap, t.clim
FROM tmp_veh t
JOIN loueur l ON l.nom = t.loueur;

-- 2 saisons pour chaque loueur
INSERT INTO saison_vehicule (id_loueur, libelle, date_debut, date_fin)
SELECT l.id, v.libelle, v.debut, v.fin
FROM tmp_loueur p
JOIN loueur l ON l.nom = p.nom
CROSS JOIN (SELECT 'Haute saison' AS libelle, DATE '2026-07-01' AS debut, DATE '2026-10-31' AS fin
            UNION ALL SELECT 'Basse saison', DATE '2026-11-01', DATE '2027-06-30') v;

-- Tarifs : base x coef saison x coef chauffeur (sans chauffeur = 80 %)
INSERT INTO tarif_vehicule (id_vehicule, id_saison_vehicule, prix_journalier, inclus_chauffeur)
SELECT ve.id, s.id,
       ROUND(t.base
             * CASE s.libelle WHEN 'Haute saison' THEN 1 ELSE 0.8 END
             * ch.coef, -3),
       ch.valeur
FROM tmp_veh t
JOIN loueur l ON l.nom = t.loueur
JOIN vehicule ve ON ve.id_loueur = l.id AND ve.modele = t.modele
JOIN saison_vehicule s ON s.id_loueur = l.id
CROSS JOIN (SELECT 1 AS valeur, 1.0 AS coef
            UNION ALL SELECT 0, 0.8) ch;

-- 3 cotations d'exemple : total = jours x véhicules x prix journalier
INSERT INTO cotation_vehicule
    (id_vehicule, id_saison_vehicule, inclus_chauffeur, nombre_jours, nombre_vehicules, total_calcule)
SELECT tv.id_vehicule, tv.id_saison_vehicule, tv.inclus_chauffeur,
       c.jours, c.nb, c.jours * c.nb * tv.prix_journalier
FROM (SELECT 'Mada 4x4 Location' AS loueur, 'Toyota Land Cruiser' AS modele,
             'Haute saison' AS saison, 1 AS chauffeur, 5 AS jours, 1 AS nb
      UNION ALL SELECT 'Nosy Be Transports', 'Hyundai Starex', 'Basse saison', 0, 3, 2
      UNION ALL SELECT 'Hauts-Plateaux Car', 'Toyota Coaster', 'Haute saison', 1, 2, 1) c
JOIN loueur l ON l.nom = c.loueur
JOIN vehicule ve ON ve.id_loueur = l.id AND ve.modele = c.modele
JOIN saison_vehicule s ON s.id_loueur = l.id AND s.libelle = c.saison
JOIN tarif_vehicule tv ON tv.id_vehicule = ve.id
                      AND tv.id_saison_vehicule = s.id
                      AND tv.inclus_chauffeur = c.chauffeur;

DROP TEMPORARY TABLE tmp_veh;
DROP TEMPORARY TABLE tmp_loueur;
