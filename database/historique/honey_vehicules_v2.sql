-- Honey Group - Base Véhicules : archivage et index de recherche
USE honey_vehicules;

-- Archivage : actif = 1 (en service) ou 0 (archivé)
ALTER TABLE loueur
    ADD COLUMN IF NOT EXISTS actif TINYINT(1) NOT NULL DEFAULT 1
        CHECK (actif IN (0, 1));

ALTER TABLE vehicule
    ADD COLUMN IF NOT EXISTS actif TINYINT(1) NOT NULL DEFAULT 1
        CHECK (actif IN (0, 1));

-- Index pour accélérer la recherche
CREATE INDEX IF NOT EXISTS idx_vehicule_categorie ON vehicule (categorie);
CREATE INDEX IF NOT EXISTS idx_vehicule_actif     ON vehicule (actif);
CREATE INDEX IF NOT EXISTS idx_loueur_actif       ON loueur (actif);
CREATE INDEX IF NOT EXISTS idx_sv_periode
    ON saison_vehicule (date_debut, date_fin);
