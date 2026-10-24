-- Retrait de la réservation et du stock (précision de M. RAKOTOARISON :
-- l'outil est une base centralisée pour coter, pas un site de réservation).
USE honey_hotels;
DROP TABLE IF EXISTS reservation;
ALTER TABLE type_chambre DROP COLUMN IF EXISTS nb_chambres;

USE honey_vehicules;
DROP TABLE IF EXISTS reservation_vehicule;
ALTER TABLE vehicule DROP COLUMN IF EXISTS nb_exemplaires;
