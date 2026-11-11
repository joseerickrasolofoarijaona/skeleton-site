-- Évolution 02 : rapprochement avec le système de cotation existant
--  1) code_externe : code du partenaire dans l'autre système (facultatif, unique)
--  2) cree_le / modifie_le : repérer ce qui a changé depuis la dernière synchronisation
--  3) vues de lecture : surface d'échange pour le système de cotation
-- Tous les montants sont en Ariary (MGA). Relançable sans erreur.

-- ======================= Base Hôtels =======================
USE honey_hotels;

ALTER TABLE hotel
    ADD COLUMN IF NOT EXISTS code_externe VARCHAR(40) NULL COMMENT 'Code de l''hôtel dans le système de cotation existant' AFTER id,
    ADD COLUMN IF NOT EXISTS cree_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Création de la ligne',
    ADD COLUMN IF NOT EXISTS modifie_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière modification';
CREATE UNIQUE INDEX IF NOT EXISTS uq_hotel_code_externe ON hotel (code_externe);

ALTER TABLE type_chambre
    ADD COLUMN IF NOT EXISTS code_externe VARCHAR(40) NULL COMMENT 'Code du type de chambre dans le système de cotation existant' AFTER id_hotel,
    ADD COLUMN IF NOT EXISTS cree_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Création de la ligne',
    ADD COLUMN IF NOT EXISTS modifie_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière modification';
CREATE UNIQUE INDEX IF NOT EXISTS uq_tc_code_externe ON type_chambre (id_hotel, code_externe);

ALTER TABLE saison
    ADD COLUMN IF NOT EXISTS cree_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Création de la ligne',
    ADD COLUMN IF NOT EXISTS modifie_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière modification';

ALTER TABLE tarif
    ADD COLUMN IF NOT EXISTS cree_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Création de la ligne',
    ADD COLUMN IF NOT EXISTS modifie_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière modification';

ALTER TABLE supplement_pension
    ADD COLUMN IF NOT EXISTS cree_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Création de la ligne',
    ADD COLUMN IF NOT EXISTS modifie_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière modification';

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

-- ====================== Base Véhicules ======================
USE honey_vehicules;

ALTER TABLE loueur
    ADD COLUMN IF NOT EXISTS code_externe VARCHAR(40) NULL COMMENT 'Code du loueur dans le système de cotation existant' AFTER id,
    ADD COLUMN IF NOT EXISTS cree_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Création de la ligne',
    ADD COLUMN IF NOT EXISTS modifie_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière modification';
CREATE UNIQUE INDEX IF NOT EXISTS uq_loueur_code_externe ON loueur (code_externe);

ALTER TABLE vehicule
    ADD COLUMN IF NOT EXISTS code_externe VARCHAR(40) NULL COMMENT 'Code du véhicule dans le système de cotation existant' AFTER id_loueur,
    ADD COLUMN IF NOT EXISTS cree_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Création de la ligne',
    ADD COLUMN IF NOT EXISTS modifie_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière modification';
CREATE UNIQUE INDEX IF NOT EXISTS uq_vehicule_code_externe ON vehicule (code_externe);

ALTER TABLE saison_vehicule
    ADD COLUMN IF NOT EXISTS cree_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Création de la ligne',
    ADD COLUMN IF NOT EXISTS modifie_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière modification';

ALTER TABLE tarif_vehicule
    ADD COLUMN IF NOT EXISTS cree_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Création de la ligne',
    ADD COLUMN IF NOT EXISTS modifie_le DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Dernière modification';

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
