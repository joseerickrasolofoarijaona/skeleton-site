-- Honey Group - Demandes de réservation (une table par base, indépendantes)

USE honey_hotels;

CREATE TABLE IF NOT EXISTS reservation (
    id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    reference              VARCHAR(20)  NOT NULL,
    id_hotel               INT UNSIGNED NOT NULL,
    id_type_chambre        INT UNSIGNED NOT NULL,
    id_supplement_pension  INT UNSIGNED NULL,
    arrivee                DATE NOT NULL,
    depart                 DATE NOT NULL,
    nb_chambres            SMALLINT UNSIGNED NOT NULL,
    nb_personnes           SMALLINT UNSIGNED NOT NULL,
    nom_client             VARCHAR(150) NOT NULL,
    email_client           VARCHAR(150) NOT NULL,
    telephone_client       VARCHAR(50)  NULL,
    message                TEXT NULL,
    total_estime           DECIMAL(14,2) NOT NULL,
    detail                 TEXT NOT NULL,
    statut                 VARCHAR(20) NOT NULL DEFAULT 'en_attente',
    note_equipe            TEXT NULL,
    cree_le                DATETIME NOT NULL,
    modifie_le             DATETIME NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_resa_reference (reference),
    KEY idx_resa_statut (statut),
    KEY idx_resa_dates (arrivee, depart),
    KEY idx_resa_hotel (id_hotel),
    CONSTRAINT ck_resa_dates CHECK (depart > arrivee),
    CONSTRAINT ck_resa_nombres CHECK (nb_chambres > 0 AND nb_personnes > 0),
    CONSTRAINT ck_resa_statut CHECK (statut IN ('en_attente','confirmee','refusee','annulee')),
    CONSTRAINT fk_resa_hotel FOREIGN KEY (id_hotel)
        REFERENCES hotel (id),
    CONSTRAINT fk_resa_type_chambre FOREIGN KEY (id_type_chambre, id_hotel)
        REFERENCES type_chambre (id, id_hotel),
    CONSTRAINT fk_resa_supplement FOREIGN KEY (id_supplement_pension, id_hotel)
        REFERENCES supplement_pension (id, id_hotel)
) ENGINE=InnoDB;


USE honey_vehicules;

CREATE TABLE IF NOT EXISTS reservation_vehicule (
    id                INT UNSIGNED NOT NULL AUTO_INCREMENT,
    reference         VARCHAR(20)  NOT NULL,
    id_vehicule       INT UNSIGNED NOT NULL,
    date_debut        DATE NOT NULL,
    date_fin          DATE NOT NULL,
    avec_chauffeur    TINYINT(1) NOT NULL,
    nb_vehicules      SMALLINT UNSIGNED NOT NULL,
    nb_personnes      SMALLINT UNSIGNED NOT NULL,
    nom_client        VARCHAR(150) NOT NULL,
    email_client      VARCHAR(150) NOT NULL,
    telephone_client  VARCHAR(50)  NULL,
    message           TEXT NULL,
    total_estime      DECIMAL(14,2) NOT NULL,
    detail            TEXT NOT NULL,
    statut            VARCHAR(20) NOT NULL DEFAULT 'en_attente',
    note_equipe       TEXT NULL,
    cree_le           DATETIME NOT NULL,
    modifie_le        DATETIME NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_resav_reference (reference),
    KEY idx_resav_statut (statut),
    KEY idx_resav_dates (date_debut, date_fin),
    KEY idx_resav_vehicule (id_vehicule),
    CONSTRAINT ck_resav_dates CHECK (date_fin >= date_debut),
    CONSTRAINT ck_resav_nombres CHECK (nb_vehicules > 0 AND nb_personnes > 0),
    CONSTRAINT ck_resav_chauffeur CHECK (avec_chauffeur IN (0, 1)),
    CONSTRAINT ck_resav_statut CHECK (statut IN ('en_attente','confirmee','refusee','annulee')),
    CONSTRAINT fk_resav_vehicule FOREIGN KEY (id_vehicule)
        REFERENCES vehicule (id)
) ENGINE=InnoDB;
