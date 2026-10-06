-- Honey Group - Base Hôtels : équipements, archivage, index de recherche
USE honey_hotels;

-- Archivage : actif = 1 (en service) ou 0 (archivé)
ALTER TABLE hotel
    ADD COLUMN IF NOT EXISTS actif TINYINT(1) NOT NULL DEFAULT 1
        CHECK (actif IN (0, 1));

-- Équipements (ex : vue panoramique)
CREATE TABLE IF NOT EXISTS equipement (
    id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    libelle  VARCHAR(100) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_equipement_libelle (libelle)
) ENGINE=InnoDB;

-- Liaison hôtel <-> équipement (un hôtel a plusieurs équipements)
CREATE TABLE IF NOT EXISTS hotel_equipement (
    id_hotel        INT UNSIGNED NOT NULL,
    id_equipement   INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_hotel, id_equipement),
    CONSTRAINT fk_he_hotel FOREIGN KEY (id_hotel)
        REFERENCES hotel (id) ON DELETE CASCADE,
    CONSTRAINT fk_he_equipement FOREIGN KEY (id_equipement)
        REFERENCES equipement (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Index pour accélérer la recherche
CREATE INDEX IF NOT EXISTS idx_hotel_localisation ON hotel (localisation);
CREATE INDEX IF NOT EXISTS idx_hotel_categorie   ON hotel (categorie);
CREATE INDEX IF NOT EXISTS idx_hotel_actif       ON hotel (actif);

-- Équipements de départ
INSERT IGNORE INTO equipement (libelle) VALUES
    ('Vue panoramique'), ('Piscine'), ('Wi-Fi'), ('Climatisation'),
    ('Restaurant'), ('Spa'), ('Parking');

-- Exemples : équipements des deux hôtels fictifs
INSERT IGNORE INTO hotel_equipement (id_hotel, id_equipement)
SELECT h.id, e.id FROM hotel h
JOIN equipement e ON e.libelle IN ('Wi-Fi', 'Restaurant', 'Climatisation')
WHERE h.nom = 'Hôtel Exemple Antananarivo';

INSERT IGNORE INTO hotel_equipement (id_hotel, id_equipement)
SELECT h.id, e.id FROM hotel h
JOIN equipement e ON e.libelle IN ('Vue panoramique', 'Piscine', 'Spa')
WHERE h.nom = 'Lodge Exemple Nosy Be';
