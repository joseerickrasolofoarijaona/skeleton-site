# Schéma relationnel (MLD) : Honey Group

Généré automatiquement depuis les bases en service. Tous les montants sont en **Ariary (MGA)**.
Deux bases **indépendantes** : aucune clé étrangère ne relie l'une à l'autre.
Le diagramme est dans `DIAGRAMME.md`, le détail des colonnes dans `DICTIONNAIRE_DONNEES.md`.

## Base Hôtels (`honey_hotels`)

| Table | Colonnes (`?` = facultatif) | Clé primaire | Clés étrangères |
|---|---|---|---|
| `destination` | id, nom, cree_le | id | n/a |
| `categorie_hotel` | id, libelle, ordre | id | n/a |
| `hotel` | id, code_externe?, nom, localisation, categorie?, contact?, remarques?, actif, cree_le, modifie_le | id | (categorie) → categorie_hotel(libelle)<br>(localisation) → destination(nom) |
| `equipement` | id, libelle | id | n/a |
| `hotel_equipement` | id_hotel, id_equipement | id_hotel, id_equipement | (id_equipement) → equipement(id)<br>(id_hotel) → hotel(id) |
| `type_chambre` | id, id_hotel, code_externe?, libelle, capacite, cree_le, modifie_le | id | (id_hotel) → hotel(id) |
| `saison` | id, id_hotel, libelle, date_debut, date_fin, cree_le, modifie_le | id | (id_hotel) → hotel(id) |
| `tarif` | id, id_type_chambre, id_saison, prix_nuitee, cree_le, modifie_le | id | (id_saison) → saison(id)<br>(id_type_chambre) → type_chambre(id) |
| `supplement_pension` | id, id_hotel, type_pension, prix_supplement, cree_le, modifie_le | id | (id_hotel) → hotel(id) |
| `cotation` | id, id_hotel, id_type_chambre, id_saison, id_supplement_pension?, nombre_nuits, total_calcule | id | (id_hotel) → hotel(id)<br>(id_saison, id_hotel) → saison(id, id_hotel)<br>(id_supplement_pension, id_hotel) → supplement_pension(id, id_hotel)<br>(id_type_chambre, id_hotel) → type_chambre(id, id_hotel) |

Vues de lecture pour le système de cotation : `v_equipements_hotel`, `v_supplements_hotel`, `v_tarifs_hotel`

## Base Véhicules (`honey_vehicules`)

| Table | Colonnes (`?` = facultatif) | Clé primaire | Clés étrangères |
|---|---|---|---|
| `type_vehicule` | id, libelle, ordre | id | n/a |
| `loueur` | id, code_externe?, nom, telephone?, email?, localisation?, remarques?, actif, cree_le, modifie_le | id | n/a |
| `vehicule` | id, id_loueur, code_externe?, modele, categorie, capacite_passagers, climatisation, remarques?, actif, cree_le, modifie_le | id | (id_loueur) → loueur(id)<br>(categorie) → type_vehicule(libelle) |
| `saison_vehicule` | id, id_loueur, libelle, date_debut, date_fin, cree_le, modifie_le | id | (id_loueur) → loueur(id) |
| `tarif_vehicule` | id, id_vehicule, id_saison_vehicule, prix_journalier, inclus_chauffeur, cree_le, modifie_le | id | (id_saison_vehicule) → saison_vehicule(id)<br>(id_vehicule) → vehicule(id) |
| `cotation_vehicule` | id, id_vehicule, id_saison_vehicule, inclus_chauffeur, nombre_jours, nombre_vehicules, total_calcule | id | (id_vehicule, id_saison_vehicule, inclus_chauffeur) → tarif_vehicule(id_vehicule, id_saison_vehicule, inclus_chauffeur) |

Vues de lecture pour le système de cotation : `v_tarifs_vehicule`

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
