-- Compte MariaDB utilisé par l'application Django (droits limités aux deux bases).
-- Remplacez le mot de passe, puis : sudo mariadb < utilisateur.sql
-- Le même mot de passe va dans backend/.env (DB_PASSWORD).
CREATE USER IF NOT EXISTS 'honey_app'@'localhost' IDENTIFIED BY 'CHANGEZ_CE_MOT_DE_PASSE';
GRANT SELECT, INSERT, UPDATE, DELETE ON honey_hotels.* TO 'honey_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON honey_vehicules.* TO 'honey_app'@'localhost';
FLUSH PRIVILEGES;
