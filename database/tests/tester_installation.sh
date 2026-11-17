#!/usr/bin/env bash
# Teste l'installation complète dans deux bases temporaires (zz_h, zz_v), puis les supprime.
# Usage : bash database/tests/tester_installation.sh
set -euo pipefail
cd "$(dirname "$0")/.."
MDB=${MDB:-"sudo mariadb"}
RENOMMER='s/honey_hotels/zz_h/g; s/honey_vehicules/zz_v/g'
trap '$MDB -e "DROP DATABASE IF EXISTS zz_h; DROP DATABASE IF EXISTS zz_v;"' EXIT
$MDB -e "DROP DATABASE IF EXISTS zz_h; DROP DATABASE IF EXISTS zz_v;"
for f in schema_complet.sql donnees_reference.sql donnees_demo.sql; do
  sed "$RENOMMER" "$f" | $MDB
done
$MDB -e "SELECT (SELECT COUNT(*) FROM zz_h.hotel) hotels, (SELECT COUNT(*) FROM zz_h.destination) destinations, (SELECT COUNT(*) FROM zz_h.v_tarifs_hotel) tarifs_vue, (SELECT COUNT(*) FROM zz_v.vehicule) vehicules, (SELECT COUNT(*) FROM zz_v.v_tarifs_vehicule) tarifs_vehicules_vue;"
echo "Installation complète testée, bases temporaires supprimées."
