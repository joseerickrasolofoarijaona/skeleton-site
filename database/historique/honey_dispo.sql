-- Honey Group - Disponibilité : stock par type de chambre et par véhicule
-- Valeurs de départ : 5 chambres par type, 3 exemplaires par véhicule
-- (à ajuster dans l'espace de gestion). Relançable sans erreur.

USE honey_hotels;
ALTER TABLE type_chambre
    ADD COLUMN IF NOT EXISTS nb_chambres SMALLINT UNSIGNED NOT NULL DEFAULT 5 AFTER capacite;
CREATE INDEX IF NOT EXISTS idx_resa_chambre_statut
    ON reservation (id_type_chambre, statut, arrivee, depart);

USE honey_vehicules;
ALTER TABLE vehicule
    ADD COLUMN IF NOT EXISTS nb_exemplaires SMALLINT UNSIGNED NOT NULL DEFAULT 3 AFTER capacite_passagers;
CREATE INDEX IF NOT EXISTS idx_resav_vehicule_statut
    ON reservation_vehicule (id_vehicule, statut, date_debut, date_fin);
