-- Honey Group - Base Véhicules : DONNÉES D'EXEMPLE (fictives)
-- À lancer UNE SEULE FOIS, après honey_vehicules.sql.

USE honey_vehicules;

-- Loueur 1
INSERT INTO loueur (nom, telephone, email, localisation, remarques)
VALUES ('Loueur Exemple Antananarivo', '+261 20 00 000 01',
        'contact@loueur-exemple.mg', 'Antananarivo', 'Données d''exemple');
SET @l1 = LAST_INSERT_ID();

INSERT INTO vehicule (id_loueur, modele, categorie, capacite_passagers, climatisation)
VALUES (@l1, 'Toyota Land Cruiser', '4x4', 7, 1);
SET @v1 = LAST_INSERT_ID();

INSERT INTO vehicule (id_loueur, modele, categorie, capacite_passagers, climatisation)
VALUES (@l1, 'Toyota HiAce', 'Minibus', 15, 1);
SET @v2 = LAST_INSERT_ID();

INSERT INTO saison_vehicule (id_loueur, libelle, date_debut, date_fin)
VALUES (@l1, 'Haute saison', '2026-07-01', '2026-10-31');
SET @s1_haute = LAST_INSERT_ID();

INSERT INTO saison_vehicule (id_loueur, libelle, date_debut, date_fin)
VALUES (@l1, 'Basse saison', '2026-11-01', '2027-06-30');
SET @s1_basse = LAST_INSERT_ID();

INSERT INTO tarif_vehicule
    (id_vehicule, id_saison_vehicule, prix_journalier, inclus_chauffeur) VALUES
    (@v1, @s1_haute, 350000, 1),
    (@v1, @s1_haute, 280000, 0),
    (@v1, @s1_basse, 300000, 1),
    (@v2, @s1_haute, 400000, 1);

-- Loueur 2 (minimal)
INSERT INTO loueur (nom, telephone, email, localisation, remarques)
VALUES ('Transports Exemple Nosy Be', '+261 20 00 000 02',
        'info@transports-exemple.mg', 'Nosy Be', 'Données d''exemple');
SET @l2 = LAST_INSERT_ID();

INSERT INTO vehicule (id_loueur, modele, categorie, capacite_passagers, climatisation)
VALUES (@l2, 'Berline Exemple', 'Berline', 4, 1);
SET @v3 = LAST_INSERT_ID();

INSERT INTO saison_vehicule (id_loueur, libelle, date_debut, date_fin)
VALUES (@l2, 'Saison sèche', '2026-05-01', '2026-11-30');
SET @s2 = LAST_INSERT_ID();

INSERT INTO tarif_vehicule
    (id_vehicule, id_saison_vehicule, prix_journalier, inclus_chauffeur)
VALUES (@v3, @s2, 150000, 1);

-- Une cotation : 5 jours, 1 véhicule, Land Cruiser, haute saison, avec chauffeur
-- total = jours x véhicules x prix journalier
INSERT INTO cotation_vehicule
    (id_vehicule, id_saison_vehicule, inclus_chauffeur,
     nombre_jours, nombre_vehicules, total_calcule)
SELECT tv.id_vehicule, tv.id_saison_vehicule, tv.inclus_chauffeur,
       5, 1, 5 * 1 * tv.prix_journalier
FROM tarif_vehicule tv
WHERE tv.id_vehicule = @v1
  AND tv.id_saison_vehicule = @s1_haute
  AND tv.inclus_chauffeur = 1;
