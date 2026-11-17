#!/usr/bin/env bash
# Régénère schema_complet.sql, donnees_reference.sql et donnees_demo.sql depuis les bases en service.
# Usage : bash database/outils/exporter.sh
set -euo pipefail
cd "$(dirname "$0")/.."
MDB=${MDB:-"sudo mariadb"}
DUMP=${DUMP:-$(command -v mariadb-dump || command -v mysqldump)}
DUMPCMD=${DUMPCMD:-"sudo $DUMP"}

tables() {
  $MDB -N -B -e "SELECT GROUP_CONCAT(TABLE_NAME ORDER BY TABLE_NAME SEPARATOR ' ') FROM information_schema.TABLES WHERE TABLE_SCHEMA='$1' AND TABLE_TYPE='BASE TABLE'"
}
sans() { tr ' ' '\n' | grep -vxE "$1" | tr '\n' ' '; }

TH=$(tables honey_hotels)
TV=$(tables honey_vehicules)
REF_H="destination categorie_hotel equipement"
REF_V="type_vehicule"
DEMO_H=$(echo "$TH" | sans "destination|categorie_hotel|equipement")
DEMO_V=$(echo "$TV" | sans "type_vehicule")

{
  echo "-- Honey Group : structure complète des deux bases (indépendantes)."
  echo "-- Générée depuis les bases testées. Ordre d'installation :"
  echo "--   schema_complet.sql, donnees_reference.sql, donnees_demo.sql (facultatif), utilisateur.sql"
  echo "CREATE DATABASE IF NOT EXISTS honey_hotels CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  echo "USE honey_hotels;"
  $DUMPCMD --no-data --skip-add-drop-table --skip-comments honey_hotels $TH | sed 's/^CREATE TABLE /CREATE TABLE IF NOT EXISTS /'
  echo "CREATE DATABASE IF NOT EXISTS honey_vehicules CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  echo "USE honey_vehicules;"
  $DUMPCMD --no-data --skip-add-drop-table --skip-comments honey_vehicules $TV | sed 's/^CREATE TABLE /CREATE TABLE IF NOT EXISTS /'
  cat vues_cotation.sql
} > schema_complet.sql

{
  echo "-- Honey Group : listes de référence (destinations, catégories, équipements, types de véhicule)."
  echo "-- Obligatoires : la base refuse les valeurs absentes de ces listes."
  echo "USE honey_hotels;"
  $DUMPCMD --no-create-info --complete-insert --insert-ignore --skip-comments --skip-add-locks honey_hotels $REF_H
  echo "USE honey_vehicules;"
  $DUMPCMD --no-create-info --complete-insert --insert-ignore --skip-comments --skip-add-locks honey_vehicules $REF_V
} > donnees_reference.sql

{
  echo "-- Honey Group : données de démonstration (noms, contacts et prix INVENTÉS). Facultatif."
  echo "USE honey_hotels;"
  $DUMPCMD --no-create-info --complete-insert --skip-comments --skip-add-locks honey_hotels $DEMO_H
  echo "USE honey_vehicules;"
  $DUMPCMD --no-create-info --complete-insert --skip-comments --skip-add-locks honey_vehicules $DEMO_V
} > donnees_demo.sql

echo "schema_complet.sql, donnees_reference.sql et donnees_demo.sql régénérés."
