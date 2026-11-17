#!/usr/bin/env bash
# Tests automatiques des règles des bases. Ne modifie aucune donnée.
# Usage : bash database/tests/lancer_tests.sh
# Autre compte : MDB="mariadb -u utilisateur -pMOTDEPASSE" bash database/tests/lancer_tests.sh
cd "$(dirname "$0")/.." || exit 1
MDB=${MDB:-"sudo mariadb"}
OK=0
ECHECS=0

echoue() {   # description, base, requête, motif de l'erreur attendue
  local err
  err=$($MDB "$2" -e "SET autocommit=0; $3; ROLLBACK;" 2>&1 >/dev/null)
  if echo "$err" | grep -qE "$4"; then
    OK=$((OK+1)); echo "OK     : $1"
  else
    ECHECS=$((ECHECS+1)); echo "ÉCHEC  : $1"; echo "         erreur reçue : ${err:-aucune (la base a accepté)}"
  fi
}
valeur() {   # description, base, requête, valeur attendue
  local v
  v=$($MDB -N -B "$2" -e "$3" 2>&1)
  if [ "$v" = "$4" ]; then
    OK=$((OK+1)); echo "OK     : $1"
  else
    ECHECS=$((ECHECS+1)); echo "ÉCHEC  : $1 (attendu $4, reçu $v)"
  fi
}
positif() {  # description, base, requête
  local v
  v=$($MDB -N -B "$2" -e "$3" 2>&1)
  if [[ "$v" =~ ^[0-9]+$ ]] && [ "$v" -gt 0 ]; then
    OK=$((OK+1)); echo "OK     : $1 ($v lignes)"
  else
    ECHECS=$((ECHECS+1)); echo "ÉCHEC  : $1 (reçu : $v)"
  fi
}
CHECK="ERROR 4025|ERROR 3819"

echo "=== Base Hôtels ==="
echoue "Une destination inconnue est refusée" honey_hotels \
  "INSERT INTO hotel (nom, localisation) VALUES ('Test', 'Ville inconnue')" "ERROR 1452"
echoue "Une catégorie inconnue est refusée" honey_hotels \
  "INSERT INTO hotel (nom, localisation, categorie) SELECT 'Test', nom, 'Categorie inconnue' FROM destination LIMIT 1" "ERROR 1452"
echoue "Une destination utilisée ne peut pas être supprimée" honey_hotels \
  "DELETE FROM destination WHERE nom IN (SELECT localisation FROM hotel)" "ERROR 1451"
echoue "Deux hôtels ne peuvent pas avoir le même code externe" honey_hotels \
  "UPDATE hotel SET code_externe='TEST-UNIQUE'" "ERROR 1062"
echoue "Un hôtel ne peut pas être créé deux fois dans la même destination" honey_hotels \
  "INSERT INTO hotel (nom, localisation, categorie) SELECT nom, localisation, categorie FROM hotel LIMIT 1" "ERROR 1062"
echoue "Une capacité de chambre doit être positive" honey_hotels \
  "UPDATE type_chambre SET capacite=0 LIMIT 1" "$CHECK"
echoue "Une saison ne peut pas finir avant de commencer" honey_hotels \
  "UPDATE saison SET date_fin=DATE_SUB(date_debut, INTERVAL 1 DAY) LIMIT 1" "$CHECK"
echoue "Un prix de nuitée ne peut pas être négatif" honey_hotels \
  "UPDATE tarif SET prix_nuitee=-1 LIMIT 1" "$CHECK"
echoue "Un tarif ne peut pas exister deux fois pour la même chambre et saison" honey_hotels \
  "INSERT INTO tarif (id_type_chambre, id_saison, prix_nuitee) SELECT id_type_chambre, id_saison, 1 FROM tarif LIMIT 1" "ERROR 1062"
echoue "Une cotation ne peut pas mélanger une chambre et la saison d'un autre hôtel" honey_hotels \
  "INSERT INTO cotation (id_hotel, id_type_chambre, id_saison, nombre_nuits, total_calcule) SELECT tc.id_hotel, tc.id, s.id, 1, 1 FROM type_chambre tc JOIN saison s ON s.id_hotel <> tc.id_hotel LIMIT 1" "ERROR 1452"

echo "=== Base Véhicules ==="
echoue "Un type de véhicule inconnu est refusé" honey_vehicules \
  "INSERT INTO vehicule (id_loueur, modele, categorie, capacite_passagers, climatisation) SELECT id, 'Test', 'Type inconnu', 4, 0 FROM loueur LIMIT 1" "ERROR 1452"
echoue "Deux loueurs ne peuvent pas avoir le même nom" honey_vehicules \
  "INSERT INTO loueur (nom) SELECT nom FROM loueur LIMIT 1" "ERROR 1062"
echoue "Une saison de véhicule ne peut pas finir avant de commencer" honey_vehicules \
  "UPDATE saison_vehicule SET date_fin=DATE_SUB(date_debut, INTERVAL 1 DAY) LIMIT 1" "$CHECK"
echoue "Un prix journalier ne peut pas être négatif" honey_vehicules \
  "UPDATE tarif_vehicule SET prix_journalier=-1 LIMIT 1" "$CHECK"
echoue "Une cotation de véhicule exige un tarif existant" honey_vehicules \
  "INSERT INTO cotation_vehicule (id_vehicule, id_saison_vehicule, inclus_chauffeur, nombre_jours, nombre_vehicules, total_calcule) SELECT v.id, s.id, 1, 1, 1, 1 FROM vehicule v JOIN saison_vehicule s ON s.id_loueur <> v.id_loueur LIMIT 1" "ERROR 1452"

echo "=== Vues et indépendance ==="
positif "La vue v_tarifs_hotel renvoie des tarifs" honey_hotels "SELECT COUNT(*) FROM v_tarifs_hotel"
positif "La vue v_tarifs_vehicule renvoie des tarifs" honey_vehicules "SELECT COUNT(*) FROM v_tarifs_vehicule"
valeur "La base Hôtels ne dépend d'aucune autre base" honey_hotels \
  "SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA='honey_hotels' AND REFERENCED_TABLE_SCHEMA IS NOT NULL AND REFERENCED_TABLE_SCHEMA<>'honey_hotels'" 0
valeur "La base Véhicules ne dépend d'aucune autre base" honey_vehicules \
  "SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA='honey_vehicules' AND REFERENCED_TABLE_SCHEMA IS NOT NULL AND REFERENCED_TABLE_SCHEMA<>'honey_vehicules'" 0
valeur "Un hôtel est en service par défaut" honey_hotels \
  "SELECT COLUMN_DEFAULT FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='honey_hotels' AND TABLE_NAME='hotel' AND COLUMN_NAME='actif'" 1

echo
echo "Résultat : $OK réussis, $ECHECS échec(s)"
[ "$ECHECS" -eq 0 ]
