-- Évolution 03 : listes de référence (destinations, catégories d'hôtel, types de véhicule)
-- Une valeur absente de la liste est refusée par la base. Relançable sans erreur.

-- ======================= Base Hôtels =======================
USE honey_hotels;

CREATE TABLE IF NOT EXISTS destination (
    id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom      VARCHAR(150) NOT NULL,
    cree_le  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_destination_nom (nom)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS categorie_hotel (
    id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    libelle  VARCHAR(50) NOT NULL,
    ordre    SMALLINT UNSIGNED NOT NULL DEFAULT 99,
    PRIMARY KEY (id),
    UNIQUE KEY uq_categorie_hotel_libelle (libelle)
) ENGINE=InnoDB;

INSERT IGNORE INTO categorie_hotel (libelle, ordre) VALUES
    ('1 étoile', 1), ('2 étoiles', 2), ('3 étoiles', 3), ('4 étoiles', 4), ('5 étoiles', 5);
INSERT IGNORE INTO categorie_hotel (libelle, ordre)
    SELECT DISTINCT categorie, 99 FROM hotel WHERE categorie IS NOT NULL;

INSERT IGNORE INTO destination (nom) VALUES
    ('Antananarivo'), ('Antsirabe'), ('Fianarantsoa'), ('Toamasina'), ('Mahajanga'),
    ('Antsiranana'), ('Toliara'), ('Nosy Be'), ('Sainte-Marie'), ('Morondava'),
    ('Taolagnaro'), ('Isalo'), ('Andasibe'), ('Ranomafana'), ('Bekopaka');
INSERT IGNORE INTO destination (nom) SELECT DISTINCT localisation FROM hotel;

ALTER TABLE hotel DROP FOREIGN KEY IF EXISTS fk_hotel_destination;
ALTER TABLE hotel ADD CONSTRAINT fk_hotel_destination
    FOREIGN KEY (localisation) REFERENCES destination (nom)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE hotel DROP FOREIGN KEY IF EXISTS fk_hotel_categorie;
ALTER TABLE hotel ADD CONSTRAINT fk_hotel_categorie
    FOREIGN KEY (categorie) REFERENCES categorie_hotel (libelle)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- ====================== Base Véhicules ======================
USE honey_vehicules;

CREATE TABLE IF NOT EXISTS type_vehicule (
    id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    libelle  VARCHAR(50) NOT NULL,
    ordre    SMALLINT UNSIGNED NOT NULL DEFAULT 99,
    PRIMARY KEY (id),
    UNIQUE KEY uq_type_vehicule_libelle (libelle)
) ENGINE=InnoDB;

INSERT IGNORE INTO type_vehicule (libelle, ordre) VALUES
    ('4x4', 1), ('Minibus', 2), ('Berline', 3), ('Autocar', 4);
INSERT IGNORE INTO type_vehicule (libelle, ordre)
    SELECT DISTINCT categorie, 99 FROM vehicule;

ALTER TABLE vehicule DROP FOREIGN KEY IF EXISTS fk_vehicule_type;
ALTER TABLE vehicule ADD CONSTRAINT fk_vehicule_type
    FOREIGN KEY (categorie) REFERENCES type_vehicule (libelle)
    ON UPDATE CASCADE ON DELETE RESTRICT;
