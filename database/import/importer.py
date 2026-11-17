#!/usr/bin/env python3
"""Import de tarifs depuis des fichiers CSV (UTF-8, séparateur « ; »).

Usage (depuis backend/, environnement activé) :
    python ../database/import/importer.py hotels_tarifs    fichier.csv [--simulation]
    python ../database/import/importer.py hotels_pensions  fichier.csv [--simulation]
    python ../database/import/importer.py vehicules_tarifs fichier.csv [--simulation]

Une ligne = un tarif. Les partenaires, types de chambre, saisons et véhicules sont créés
ou mis à jour. Les destinations, catégories et types de véhicule doivent exister dans les
listes de référence. Si une ligne est invalide, RIEN n'est enregistré.
"""
import argparse
import csv
import os
import sys
from datetime import datetime
from decimal import Decimal, InvalidOperation
from pathlib import Path

import MySQLdb
from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[2] / "backend" / ".env")


class Erreur(Exception):
    """Erreur de contenu dans une ligne du fichier."""


def texte(ligne, cle, obligatoire=False):
    valeur = (ligne.get(cle) or "").strip()
    if obligatoire and not valeur:
        raise Erreur(f"la colonne « {cle} » est vide")
    return valeur


def entier(ligne, cle):
    brut = texte(ligne, cle, True)
    try:
        n = int(brut)
    except ValueError:
        raise Erreur(f"« {cle} » doit être un nombre entier (valeur : {brut})")
    if n < 1:
        raise Erreur(f"« {cle} » doit être supérieur à 0 (valeur : {brut})")
    return n


def montant(ligne, cle):
    brut = texte(ligne, cle, True).replace(" ", "").replace("\u202f", "").replace(",", ".")
    try:
        valeur = Decimal(brut)
    except InvalidOperation:
        raise Erreur(f"« {cle} » : montant invalide « {brut} »")
    if not valeur.is_finite() or valeur < 0 or valeur > Decimal("9999999999"):
        raise Erreur(f"« {cle} » : montant hors limites « {brut} »")
    return valeur.quantize(Decimal("0.01"))


def jour(ligne, cle):
    brut = texte(ligne, cle, True)
    for format_ in ("%Y-%m-%d", "%d/%m/%Y"):
        try:
            return datetime.strptime(brut, format_).date()
        except ValueError:
            pass
    raise Erreur(f"« {cle} » : date invalide « {brut} » (AAAA-MM-JJ ou JJ/MM/AAAA)")


def periode(ligne):
    debut, fin = jour(ligne, "date_debut"), jour(ligne, "date_fin")
    if fin < debut:
        raise Erreur("« date_fin » est avant « date_debut »")
    return debut, fin


def oui_non(ligne, cle, obligatoire=False):
    brut = texte(ligne, cle).lower()
    if not brut:
        if obligatoire:
            raise Erreur(f"la colonne « {cle} » est vide (oui ou non)")
        return None
    if brut in ("oui", "o", "1", "vrai", "true", "yes"):
        return True
    if brut in ("non", "n", "0", "faux", "false", "no"):
        return False
    raise Erreur(f"« {cle} » doit être oui ou non (valeur : {brut})")


def canonique(cur, table, colonne, valeur, nom):
    """Renvoie la valeur telle qu'elle est écrite dans la liste de référence."""
    cur.execute(f"SELECT {colonne} FROM {table} WHERE {colonne} = %s", (valeur,))
    ligne = cur.fetchone()
    if not ligne:
        raise Erreur(f"{nom} inconnu(e) : « {valeur} » (à ajouter d'abord dans la liste « {table} »)")
    return ligne[0]


def identifiant(cur, sql, params):
    cur.execute(sql, params)
    ligne = cur.fetchone()
    return ligne[0] if ligne else None


# ---------------------------------------------------------------------
# Hôtels
# ---------------------------------------------------------------------
def ligne_hotel_tarif(cur, l):
    nom = texte(l, "hotel", True)
    destination = canonique(cur, "destination", "nom", texte(l, "destination", True), "destination")
    categorie = texte(l, "categorie")
    categorie = canonique(cur, "categorie_hotel", "libelle", categorie, "catégorie") if categorie else None
    contact = texte(l, "contact") or None
    code = texte(l, "code_externe_hotel") or None
    chambre = texte(l, "type_chambre", True)
    capacite = entier(l, "capacite")
    saison = texte(l, "saison", True)
    debut, fin = periode(l)
    prix = montant(l, "prix_nuitee_mga")

    hotel_id = identifiant(cur, "SELECT id FROM hotel WHERE nom = %s AND localisation = %s", (nom, destination))
    if hotel_id:
        for champ, valeur in (("categorie", categorie), ("contact", contact), ("code_externe", code)):
            if valeur is not None:
                cur.execute(f"UPDATE hotel SET {champ} = %s WHERE id = %s", (valeur, hotel_id))
    else:
        cur.execute("INSERT INTO hotel (nom, localisation, categorie, contact, code_externe) "
                    "VALUES (%s, %s, %s, %s, %s)", (nom, destination, categorie, contact, code))
        hotel_id = cur.lastrowid

    for equipement in [e.strip() for e in texte(l, "equipements").split("|") if e.strip()]:
        cur.execute("INSERT IGNORE INTO equipement (libelle) VALUES (%s)", (equipement,))
        equipement_id = identifiant(cur, "SELECT id FROM equipement WHERE libelle = %s", (equipement,))
        cur.execute("INSERT IGNORE INTO hotel_equipement (id_hotel, id_equipement) VALUES (%s, %s)",
                    (hotel_id, equipement_id))

    chambre_id = identifiant(cur, "SELECT id FROM type_chambre WHERE id_hotel = %s AND libelle = %s",
                             (hotel_id, chambre))
    if chambre_id:
        cur.execute("UPDATE type_chambre SET capacite = %s WHERE id = %s", (capacite, chambre_id))
    else:
        cur.execute("INSERT INTO type_chambre (id_hotel, libelle, capacite) VALUES (%s, %s, %s)",
                    (hotel_id, chambre, capacite))
        chambre_id = cur.lastrowid

    saison_id = identifiant(cur, "SELECT id FROM saison WHERE id_hotel = %s AND libelle = %s", (hotel_id, saison))
    if saison_id:
        cur.execute("UPDATE saison SET date_debut = %s, date_fin = %s WHERE id = %s", (debut, fin, saison_id))
    else:
        cur.execute("INSERT INTO saison (id_hotel, libelle, date_debut, date_fin) VALUES (%s, %s, %s, %s)",
                    (hotel_id, saison, debut, fin))
        saison_id = cur.lastrowid

    tarif_id = identifiant(cur, "SELECT id FROM tarif WHERE id_type_chambre = %s AND id_saison = %s",
                           (chambre_id, saison_id))
    if tarif_id:
        cur.execute("UPDATE tarif SET prix_nuitee = %s WHERE id = %s", (prix, tarif_id))
    else:
        cur.execute("INSERT INTO tarif (id_type_chambre, id_saison, prix_nuitee) VALUES (%s, %s, %s)",
                    (chambre_id, saison_id, prix))


def ligne_hotel_pension(cur, l):
    nom = texte(l, "hotel", True)
    destination = canonique(cur, "destination", "nom", texte(l, "destination", True), "destination")
    pension = texte(l, "type_pension", True)
    prix = montant(l, "prix_supplement_mga")
    hotel_id = identifiant(cur, "SELECT id FROM hotel WHERE nom = %s AND localisation = %s", (nom, destination))
    if not hotel_id:
        raise Erreur(f"hôtel inconnu : « {nom} » à {destination} (importez d'abord ses tarifs)")
    supplement_id = identifiant(cur, "SELECT id FROM supplement_pension WHERE id_hotel = %s AND type_pension = %s",
                                (hotel_id, pension))
    if supplement_id:
        cur.execute("UPDATE supplement_pension SET prix_supplement = %s WHERE id = %s", (prix, supplement_id))
    else:
        cur.execute("INSERT INTO supplement_pension (id_hotel, type_pension, prix_supplement) VALUES (%s, %s, %s)",
                    (hotel_id, pension, prix))


# ---------------------------------------------------------------------
# Véhicules
# ---------------------------------------------------------------------
def ligne_vehicule_tarif(cur, l):
    nom_loueur = texte(l, "loueur", True)
    ville = texte(l, "ville") or None
    telephone = texte(l, "telephone") or None
    email = texte(l, "email") or None
    modele = texte(l, "modele", True)
    type_ = canonique(cur, "type_vehicule", "libelle", texte(l, "type", True), "type de véhicule")
    places = entier(l, "places")
    climatisation = oui_non(l, "climatisation")
    code = texte(l, "code_externe_vehicule") or None
    saison = texte(l, "saison", True)
    debut, fin = periode(l)
    avec_chauffeur = 1 if oui_non(l, "avec_chauffeur", True) else 0
    prix = montant(l, "prix_journalier_mga")

    loueur_id = identifiant(cur, "SELECT id FROM loueur WHERE nom = %s", (nom_loueur,))
    if loueur_id:
        for champ, valeur in (("localisation", ville), ("telephone", telephone), ("email", email)):
            if valeur is not None:
                cur.execute(f"UPDATE loueur SET {champ} = %s WHERE id = %s", (valeur, loueur_id))
    else:
        cur.execute("INSERT INTO loueur (nom, localisation, telephone, email) VALUES (%s, %s, %s, %s)",
                    (nom_loueur, ville, telephone, email))
        loueur_id = cur.lastrowid

    vehicule_id = identifiant(cur, "SELECT id FROM vehicule WHERE id_loueur = %s AND modele = %s",
                              (loueur_id, modele))
    if vehicule_id:
        cur.execute("UPDATE vehicule SET categorie = %s, capacite_passagers = %s WHERE id = %s",
                    (type_, places, vehicule_id))
        if climatisation is not None:
            cur.execute("UPDATE vehicule SET climatisation = %s WHERE id = %s", (int(climatisation), vehicule_id))
        if code is not None:
            cur.execute("UPDATE vehicule SET code_externe = %s WHERE id = %s", (code, vehicule_id))
    else:
        cur.execute("INSERT INTO vehicule (id_loueur, modele, categorie, capacite_passagers, climatisation, "
                    "code_externe) VALUES (%s, %s, %s, %s, %s, %s)",
                    (loueur_id, modele, type_, places, int(bool(climatisation)), code))
        vehicule_id = cur.lastrowid

    saison_id = identifiant(cur, "SELECT id FROM saison_vehicule WHERE id_loueur = %s AND libelle = %s",
                            (loueur_id, saison))
    if saison_id:
        cur.execute("UPDATE saison_vehicule SET date_debut = %s, date_fin = %s WHERE id = %s",
                    (debut, fin, saison_id))
    else:
        cur.execute("INSERT INTO saison_vehicule (id_loueur, libelle, date_debut, date_fin) VALUES (%s, %s, %s, %s)",
                    (loueur_id, saison, debut, fin))
        saison_id = cur.lastrowid

    tarif_id = identifiant(cur, "SELECT id FROM tarif_vehicule WHERE id_vehicule = %s AND id_saison_vehicule = %s "
                                "AND inclus_chauffeur = %s", (vehicule_id, saison_id, avec_chauffeur))
    if tarif_id:
        cur.execute("UPDATE tarif_vehicule SET prix_journalier = %s WHERE id = %s", (prix, tarif_id))
    else:
        cur.execute("INSERT INTO tarif_vehicule (id_vehicule, id_saison_vehicule, prix_journalier, inclus_chauffeur) "
                    "VALUES (%s, %s, %s, %s)", (vehicule_id, saison_id, prix, avec_chauffeur))


TYPES = {
    "hotels_tarifs": ("honey_hotels", ligne_hotel_tarif,
                      ["hotel", "destination", "type_chambre", "capacite", "saison",
                       "date_debut", "date_fin", "prix_nuitee_mga"]),
    "hotels_pensions": ("honey_hotels", ligne_hotel_pension,
                        ["hotel", "destination", "type_pension", "prix_supplement_mga"]),
    "vehicules_tarifs": ("honey_vehicules", ligne_vehicule_tarif,
                         ["loueur", "modele", "type", "places", "saison", "date_debut",
                          "date_fin", "avec_chauffeur", "prix_journalier_mga"]),
}


def main():
    p = argparse.ArgumentParser(description="Import de tarifs depuis un fichier CSV.")
    p.add_argument("type", choices=sorted(TYPES))
    p.add_argument("fichier")
    p.add_argument("--simulation", action="store_true", help="vérifie tout sans rien enregistrer")
    p.add_argument("--separateur", default=";")
    a = p.parse_args()
    base, traiter, requises = TYPES[a.type]

    with open(a.fichier, encoding="utf-8-sig", newline="") as f:
        lecteur = csv.DictReader(f, delimiter=a.separateur)
        entetes = [h.strip() for h in (lecteur.fieldnames or [])]
        manquantes = [c for c in requises if c not in entetes]
        if manquantes:
            sys.exit("Colonnes manquantes : " + ", ".join(manquantes)
                     + "\n(Si le fichier est séparé par des virgules, ajoutez --separateur ,)")
        lecteur.fieldnames = entetes
        lignes = [l for l in lecteur if any((v or "").strip() for v in l.values() if not isinstance(v, list))]
    if not lignes:
        sys.exit("Le fichier ne contient aucune ligne de données.")

    cnx = MySQLdb.connect(host=os.environ.get("DB_HOST", "localhost"), user=os.environ["DB_USER"],
                          passwd=os.environ["DB_PASSWORD"], db=base, charset="utf8mb4", autocommit=False)
    cur = cnx.cursor()
    erreurs = []
    for numero, l in enumerate(lignes, start=2):
        try:
            traiter(cur, l)
        except Erreur as e:
            erreurs.append((numero, str(e)))
        except MySQLdb.Error as e:
            erreurs.append((numero, f"refusé par la base : {e}"))

    if erreurs:
        cnx.rollback()
        print(f"{len(erreurs)} erreur(s) : RIEN n'a été enregistré.")
        for numero, message in erreurs:
            print(f"  ligne {numero} : {message}")
        sys.exit(1)
    if a.simulation:
        cnx.rollback()
        print(f"Simulation réussie : {len(lignes)} ligne(s) valides. Rien n'a été enregistré.")
    else:
        cnx.commit()
        print(f"{len(lignes)} ligne(s) importée(s).")


if __name__ == "__main__":
    main()
