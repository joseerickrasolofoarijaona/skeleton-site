#!/usr/bin/env python3
"""Génère DICTIONNAIRE_DONNEES.md et MLD.md à partir des bases en service.

Usage (depuis backend/, environnement activé) :
    python ../database/outils/generer_documentation.py
"""
import os
from collections import OrderedDict
from pathlib import Path

import MySQLdb
from dotenv import load_dotenv

DOSSIER = Path(__file__).resolve().parents[1]
load_dotenv(DOSSIER.parent / "backend" / ".env")

BASES = [("honey_hotels", "Base Hôtels"), ("honey_vehicules", "Base Véhicules")]

ORDRE = {
    "honey_hotels": ["destination", "categorie_hotel", "hotel", "equipement", "hotel_equipement",
                     "type_chambre", "saison", "tarif", "supplement_pension", "cotation"],
    "honey_vehicules": ["type_vehicule", "loueur", "vehicule", "saison_vehicule",
                        "tarif_vehicule", "cotation_vehicule"],
}

TABLES = {
    "destination": "Liste de référence des destinations. Un hôtel ne peut être rattaché qu'à une destination de cette liste.",
    "categorie_hotel": "Liste de référence des catégories d'hôtel (étoiles).",
    "hotel": "Hôtels partenaires. Un hôtel n'est jamais supprimé : il est archivé (colonne actif).",
    "equipement": "Liste des équipements possibles (piscine, wi-fi, vue panoramique...).",
    "hotel_equipement": "Équipements de chaque hôtel (liaison plusieurs-à-plusieurs).",
    "type_chambre": "Types de chambre proposés par chaque hôtel.",
    "saison": "Périodes tarifaires propres à chaque hôtel (haute saison, basse saison...).",
    "tarif": "Prix de la nuitée, en Ariary (MGA), par type de chambre et par saison.",
    "supplement_pension": "Formules de pension et leur supplément par nuit et par chambre.",
    "cotation": "Cotations d'hôtel : réservée au raccordement avec le système de cotation.",
    "type_vehicule": "Liste de référence des types de véhicule (4x4, minibus...).",
    "loueur": "Loueurs de véhicules partenaires. Un loueur n'est jamais supprimé : il est archivé.",
    "vehicule": "Flotte de chaque loueur.",
    "saison_vehicule": "Périodes tarifaires propres à chaque loueur.",
    "tarif_vehicule": "Prix journalier, en Ariary (MGA), par véhicule, par saison, avec ou sans chauffeur.",
    "cotation_vehicule": "Cotations de véhicule : réservée au raccordement avec le système de cotation.",
    "v_tarifs_hotel": "Vue de lecture : tous les tarifs d'hôtel par type de chambre et par saison.",
    "v_supplements_hotel": "Vue de lecture : suppléments de pension de chaque hôtel.",
    "v_equipements_hotel": "Vue de lecture : équipements de chaque hôtel.",
    "v_tarifs_vehicule": "Vue de lecture : tous les tarifs de véhicule par saison et par option chauffeur.",
}

COLONNES = {
    "id": "Identifiant technique (clé primaire).",
    "code_externe": "Code du partenaire dans le système de cotation existant (facultatif, unique).",
    "cree_le": "Date de création de la ligne (automatique).",
    "modifie_le": "Date de dernière modification (automatique).",
    "actif": "1 = en service, 0 = archivé.",
    "remarques": "Remarques libres.",
    "contact": "Téléphone ou e-mail.",
    "telephone": "Numéro de téléphone.",
    "email": "Adresse e-mail.",
    "capacite": "Nombre de personnes que la chambre accueille.",
    "date_debut": "Premier jour de la période.",
    "date_fin": "Dernier jour de la période (inclus).",
    "prix_nuitee": "Prix d'une nuit, en Ariary (MGA).",
    "type_pension": "Formule de pension (ex. Demi-pension).",
    "prix_supplement": "Supplément par nuit et par chambre, en Ariary (MGA).",
    "nombre_nuits": "Nombre de nuits.",
    "total_calcule": "Total calculé, en Ariary (MGA).",
    "ordre": "Ordre d'affichage dans les listes.",
    "modele": "Modèle du véhicule (ex. Toyota Land Cruiser).",
    "capacite_passagers": "Nombre de places passagers.",
    "climatisation": "1 = climatisé, 0 = non.",
    "prix_journalier": "Prix d'une journée de location, en Ariary (MGA).",
    "inclus_chauffeur": "1 = avec chauffeur, 0 = sans chauffeur.",
    "nombre_jours": "Nombre de jours de location (premier et dernier jour inclus).",
    "nombre_vehicules": "Nombre de véhicules loués.",
}

SPECIFIQUES = {
    "destination.nom": "Nom de la destination (ex. Nosy Be).",
    "categorie_hotel.libelle": "Catégorie (ex. 4 étoiles).",
    "hotel.nom": "Nom de l'hôtel.",
    "hotel.localisation": "Destination (liste de référence destination).",
    "hotel.categorie": "Catégorie (liste de référence categorie_hotel).",
    "equipement.libelle": "Nom de l'équipement (ex. Piscine).",
    "type_chambre.libelle": "Nom du type de chambre (ex. Chambre double).",
    "saison.libelle": "Nom de la saison (ex. Haute saison), propre à l'hôtel.",
    "type_vehicule.libelle": "Type de véhicule (ex. 4x4).",
    "loueur.nom": "Nom du loueur.",
    "loueur.localisation": "Ville du loueur.",
    "vehicule.categorie": "Type de véhicule (liste de référence type_vehicule).",
    "saison_vehicule.libelle": "Nom de la saison (ex. Haute saison), propre au loueur.",
}

NOTES = """
## Adaptations par rapport aux MCD fournis

- `saison` (hôtels) : ajout de `id_hotel` (la flèche « concerne » n'avait pas de colonne).
- `saison_vehicule` : ajout de `id_loueur`, pour la même raison.
- `cotation` : ajout de `id_supplement_pension` (facultatif).
- `loueur` : le champ `contact` en double devient `telephone` et `email`.
- `vehicule` : `modeIe` corrigé en `modele`, `climatique` en `climatisation`.
- `cotation_vehicule` : le second `nombre_jours` devient `nombre_vehicules` ; ajout de `inclus_chauffeur`.
- Listes de référence `destination`, `categorie_hotel`, `type_vehicule` : la base refuse toute valeur absente de la liste.
- `code_externe` (hôtel, type de chambre, loueur, véhicule) : point d'accroche avec le système de cotation existant.
- `actif` (archivage), `equipement` et `hotel_equipement` (filtre par équipement), `cree_le` et `modifie_le`.
- Les clés étrangères composées (id, id_hotel) garantissent qu'une cotation ne mélange pas les éléments de deux hôtels.
- Les deux bases sont indépendantes : aucune clé étrangère ne les relie.
"""


def s(valeur):
    if valeur is None:
        return ""
    if isinstance(valeur, (bytes, bytearray)):
        return valeur.decode("utf-8")
    return str(valeur)


def echapper(texte):
    return s(texte).replace("|", "\\|").replace("\n", " ")


def lire(cur, sql, params=()):
    cur.execute(sql, params)
    return cur.fetchall()


def description(table, col, cible, est_vue):
    if f"{table}.{col}" in SPECIFIQUES:
        return SPECIFIQUES[f"{table}.{col}"]
    if col in COLONNES:
        return COLONNES[col]
    if cible:
        return f"Clé étrangère vers {cible}."
    if est_vue:
        if col.endswith("_mga"):
            return "Montant en Ariary (MGA)."
        if col.endswith("_code"):
            return "Code technique mis en forme. Pour le rapprochement, utiliser le code externe."
        return "Valeur reprise de la table d'origine."
    return ""


def documenter(cnx, base, titre):
    cur = cnx.cursor()
    types = {s(n): s(t) for n, t in lire(
        cur, "SELECT TABLE_NAME, TABLE_TYPE FROM information_schema.TABLES WHERE TABLE_SCHEMA=%s", (base,))}
    colonnes = OrderedDict()
    for t, c, typ, nul, cle, defaut in lire(
            cur, "SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_DEFAULT "
                 "FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=%s "
                 "ORDER BY TABLE_NAME, ORDINAL_POSITION", (base,)):
        colonnes.setdefault(s(t), []).append(
            {"nom": s(c), "type": s(typ), "nul": s(nul) == "YES", "cle": s(cle), "defaut": s(defaut)})

    pks, fks = {}, OrderedDict()
    for t, col in lire(
            cur, "SELECT TABLE_NAME, COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE "
                 "WHERE TABLE_SCHEMA=%s AND CONSTRAINT_NAME='PRIMARY' "
                 "ORDER BY TABLE_NAME, ORDINAL_POSITION", (base,)):
        pks.setdefault(s(t), []).append(s(col))
    for t, cn, col, rt, rc in lire(
            cur, "SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, "
                 "REFERENCED_COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE "
                 "WHERE TABLE_SCHEMA=%s AND REFERENCED_TABLE_NAME IS NOT NULL "
                 "ORDER BY TABLE_NAME, CONSTRAINT_NAME, ORDINAL_POSITION", (base,)):
        fks.setdefault((s(t), s(cn)), []).append((s(col), s(rt), s(rc)))
    uniques = OrderedDict()
    for t, idx, col in lire(
            cur, "SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME FROM information_schema.STATISTICS "
                 "WHERE TABLE_SCHEMA=%s AND NON_UNIQUE=0 AND INDEX_NAME<>'PRIMARY' "
                 "ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX", (base,)):
        uniques.setdefault((s(t), s(idx)), []).append(s(col))
    try:
        checks = lire(cur, "SELECT TABLE_NAME, CONSTRAINT_NAME, CHECK_CLAUSE "
                           "FROM information_schema.CHECK_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=%s "
                           "ORDER BY TABLE_NAME, CONSTRAINT_NAME", (base,))
    except MySQLdb.Error:
        checks = []

    cible_fk = {}
    for (t, _), liste in fks.items():
        for col, rt, rc in liste:
            cible_fk.setdefault((t, col), f"{rt}({rc})")

    tables = [t for t in ORDRE[base] if t in colonnes]
    tables += sorted(t for t in colonnes if types.get(t) == "BASE TABLE" and t not in tables)
    vues = sorted(t for t in colonnes if types.get(t) == "VIEW")

    d = [f"## {titre} (`{base}`)", ""]
    m = [f"## {titre} (`{base}`)", "",
         "| Table | Colonnes (`?` = facultatif) | Clé primaire | Clés étrangères |", "|---|---|---|---|"]

    for t in tables + vues:
        est_vue = t in vues
        d += [f"### {'Vue' if est_vue else 'Table'} `{t}`", "", TABLES.get(t, ""), "",
              "| Colonne | Type | Null | Clé | Défaut | Description |", "|---|---|---|---|---|---|"]
        for c in colonnes[t]:
            marques = []
            if c["nom"] in pks.get(t, []) and not est_vue:
                marques.append("PK")
            if (t, c["nom"]) in cible_fk:
                marques.append("FK")
            if c["cle"] == "UNI":
                marques.append("unique")
            d.append("| `{}` | {} | {} | {} | {} | {} |".format(
                c["nom"], echapper(c["type"]), "oui" if c["nul"] else "non", ", ".join(marques),
                echapper(c["defaut"]), echapper(description(t, c["nom"], cible_fk.get((t, c["nom"])), est_vue))))
        d.append("")
        if not est_vue:
            lignes_fk = ["- `({})` → `{}({})`".format(
                ", ".join(x[0] for x in liste), liste[0][1], ", ".join(x[2] for x in liste))
                for (tt, _), liste in fks.items() if tt == t]
            if lignes_fk:
                d += ["**Clés étrangères**", ""] + lignes_fk + [""]
            lignes_u = ["- `{}` : ({})".format(idx, ", ".join(cols))
                        for (tt, idx), cols in uniques.items() if tt == t]
            if lignes_u:
                d += ["**Unicité**", ""] + lignes_u + [""]
            lignes_c = ["- `{}` : `{}`".format(cn, echapper(cl)) for tt, cn, cl in checks if s(tt) == t]
            if lignes_c:
                d += ["**Contrôles**", ""] + lignes_c + [""]
            noms = [c["nom"] + ("?" if c["nul"] else "") for c in colonnes[t]]
            fk_txt = "<br>".join("({}) → {}({})".format(
                ", ".join(x[0] for x in liste), liste[0][1], ", ".join(x[2] for x in liste))
                for (tt, _), liste in fks.items() if tt == t) or "n/a"
            m.append("| `{}` | {} | {} | {} |".format(
                t, ", ".join(noms), ", ".join(pks.get(t, [])) or "n/a", fk_txt))
    m += ["", "Vues de lecture pour le système de cotation : " + (", ".join(f"`{v}`" for v in vues) or "aucune"), ""]
    return d, m


def main():
    cnx = MySQLdb.connect(host=os.environ.get("DB_HOST", "localhost"), user=os.environ["DB_USER"],
                          passwd=os.environ["DB_PASSWORD"], charset="utf8mb4")
    dico = ["# Dictionnaire de données : Honey Group", "",
            "Généré automatiquement depuis les bases en service (`database/outils/generer_documentation.py`).",
            "Tous les montants sont en **Ariary (MGA)**. Les deux bases sont indépendantes.", ""]
    mld = ["# Schéma relationnel (MLD) : Honey Group", "",
           "Généré automatiquement depuis les bases en service. Tous les montants sont en **Ariary (MGA)**.",
           "Deux bases **indépendantes** : aucune clé étrangère ne relie l'une à l'autre.",
           "Le diagramme est dans `DIAGRAMME.md`, le détail des colonnes dans `DICTIONNAIRE_DONNEES.md`.", ""]
    for base, titre in BASES:
        d, m = documenter(cnx, base, titre)
        dico += d
        mld += m
    mld += NOTES.strip("\n").split("\n")
    (DOSSIER / "DICTIONNAIRE_DONNEES.md").write_text("\n".join(dico) + "\n", encoding="utf-8")
    (DOSSIER / "MLD.md").write_text("\n".join(mld) + "\n", encoding="utf-8")
    print("DICTIONNAIRE_DONNEES.md et MLD.md générés.")


if __name__ == "__main__":
    main()
