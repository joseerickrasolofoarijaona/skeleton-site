-- Honey Group - Base Hôtels : DONNÉES D'EXEMPLE (fictives)
-- À lancer UNE SEULE FOIS, après honey_hotels.sql.

USE honey_hotels;

-- Hôtel 1
INSERT INTO hotel (nom, localisation, categorie, contact, remarques)
VALUES ('Hôtel Exemple Antananarivo', 'Antananarivo', '3 étoiles',
        '+261 20 00 000 00', 'Données d''exemple');
SET @h1 = LAST_INSERT_ID();

INSERT INTO type_chambre (id_hotel, libelle, capacite)
VALUES (@h1, 'Chambre simple', 1);
SET @h1_simple = LAST_INSERT_ID();

INSERT INTO type_chambre (id_hotel, libelle, capacite)
VALUES (@h1, 'Chambre double', 2);
SET @h1_double = LAST_INSERT_ID();

INSERT INTO saison (id_hotel, libelle, date_debut, date_fin)
VALUES (@h1, 'Haute saison', '2026-07-01', '2026-10-31');
SET @h1_haute = LAST_INSERT_ID();

INSERT INTO saison (id_hotel, libelle, date_debut, date_fin)
VALUES (@h1, 'Basse saison', '2026-11-01', '2027-06-30');
SET @h1_basse = LAST_INSERT_ID();

INSERT INTO tarif (id_type_chambre, id_saison, prix_nuitee) VALUES
    (@h1_simple, @h1_haute, 100000),
    (@h1_simple, @h1_basse,  75000),
    (@h1_double, @h1_haute, 150000),
    (@h1_double, @h1_basse, 110000);

INSERT INTO supplement_pension (id_hotel, type_pension, prix_supplement)
VALUES (@h1, 'Petit-déjeuner', 15000);

INSERT INTO supplement_pension (id_hotel, type_pension, prix_supplement)
VALUES (@h1, 'Demi-pension', 40000);
SET @h1_demi = LAST_INSERT_ID();

INSERT INTO supplement_pension (id_hotel, type_pension, prix_supplement)
VALUES (@h1, 'Pension complète', 65000);

-- Hôtel 2 (minimal)
INSERT INTO hotel (nom, localisation, categorie, contact, remarques)
VALUES ('Lodge Exemple Nosy Be', 'Nosy Be', '4 étoiles',
        'contact@lodge-exemple.mg', 'Données d''exemple');
SET @h2 = LAST_INSERT_ID();

INSERT INTO type_chambre (id_hotel, libelle, capacite)
VALUES (@h2, 'Bungalow familial', 4);
SET @h2_bungalow = LAST_INSERT_ID();

INSERT INTO saison (id_hotel, libelle, date_debut, date_fin)
VALUES (@h2, 'Saison sèche', '2026-05-01', '2026-11-30');
SET @h2_seche = LAST_INSERT_ID();

INSERT INTO tarif (id_type_chambre, id_saison, prix_nuitee)
VALUES (@h2_bungalow, @h2_seche, 280000);

-- Une cotation : 3 nuits, chambre double, haute saison, demi-pension
-- total = nuits x (prix de la nuitée + supplément pension)
INSERT INTO cotation
    (id_hotel, id_type_chambre, id_saison, id_supplement_pension,
     nombre_nuits, total_calcule)
SELECT @h1, @h1_double, @h1_haute, @h1_demi,
       3, 3 * (t.prix_nuitee + sp.prix_supplement)
FROM tarif t, supplement_pension sp
WHERE t.id_type_chambre = @h1_double
  AND t.id_saison       = @h1_haute
  AND sp.id             = @h1_demi;
