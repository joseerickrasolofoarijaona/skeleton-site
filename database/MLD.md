# Schéma relationnel (MLD) : Honey Group

Deux bases **indépendantes** : aucune clé étrangère ne relie l'une à l'autre.
PK = clé primaire, FK = clé étrangère, `?` = valeur facultative.

## Base `honey_hotels`

| Table | Colonnes | PK | FK |
|---|---|---|---|
| `hotel` | id, nom, localisation, categorie?, contact?, remarques?, actif | id | n/a |
| `type_chambre` | id, id_hotel, libelle, capacite, nb_chambres (stock) | id | id_hotel → hotel |
| `saison` | id, id_hotel, libelle, date_debut, date_fin | id | id_hotel → hotel |
| `tarif` | id, id_type_chambre, id_saison, prix_nuitee | id | id_type_chambre → type_chambre ; id_saison → saison |
| `supplement_pension` | id, id_hotel, type_pension, prix_supplement | id | id_hotel → hotel |
| `cotation` | id, id_hotel, id_type_chambre, id_saison, id_supplement_pension?, nombre_nuits, total_calcule | id | id_hotel → hotel ; (id_type_chambre, id_hotel) → type_chambre ; (id_saison, id_hotel) → saison ; (id_supplement_pension, id_hotel) → supplement_pension |
| `equipement` | id, libelle | id | n/a |
| `hotel_equipement` | id_hotel, id_equipement | (id_hotel, id_equipement) | id_hotel → hotel ; id_equipement → equipement |
| `reservation` | id, reference, id_hotel, id_type_chambre, id_supplement_pension?, arrivee, depart, nb_chambres, nb_personnes, nom_client, email_client, telephone_client?, message?, total_estime, detail, statut, note_equipe?, cree_le, modifie_le | id | id_hotel → hotel ; (id_type_chambre, id_hotel) → type_chambre ; (id_supplement_pension, id_hotel) → supplement_pension |

## Base `honey_vehicules`

| Table | Colonnes | PK | FK |
|---|---|---|---|
| `loueur` | id, nom, telephone?, email?, localisation?, remarques?, actif | id | n/a |
| `vehicule` | id, id_loueur, modele, categorie, capacite_passagers, nb_exemplaires (stock), climatisation, remarques?, actif | id | id_loueur → loueur |
| `saison_vehicule` | id, id_loueur, libelle, date_debut, date_fin | id | id_loueur → loueur |
| `tarif_vehicule` | id, id_vehicule, id_saison_vehicule, prix_journalier, inclus_chauffeur | id | id_vehicule → vehicule ; id_saison_vehicule → saison_vehicule |
| `cotation_vehicule` | id, id_vehicule, id_saison_vehicule, inclus_chauffeur, nombre_jours, nombre_vehicules, total_calcule | id | (id_vehicule, id_saison_vehicule, inclus_chauffeur) → tarif_vehicule |
| `reservation_vehicule` | id, reference, id_vehicule, date_debut, date_fin, avec_chauffeur, nb_vehicules, nb_personnes, nom_client, email_client, telephone_client?, message?, total_estime, detail, statut, note_equipe?, cree_le, modifie_le | id | id_vehicule → vehicule |

## Adaptations par rapport aux MCD fournis

- `saison` (hôtels) : ajout de `id_hotel` (la flèche « concerne » n'avait pas de colonne).
- `saison_vehicule` : ajout de `id_loueur`, pour la même raison.
- `cotation` : ajout de `id_supplement_pension` (facultatif).
- `loueur` : le champ `contact` en double devient `telephone` et `email`.
- `vehicule` : `modeIe` corrigé en `modele`, `climatique` en `climatisation`.
- `cotation_vehicule` : le second `nombre_jours` devient `nombre_vehicules` ; ajout de `inclus_chauffeur`.
- Ajouts pour la mission : `actif` (archivage), `equipement` et `hotel_equipement` (filtre par équipement), `nb_chambres` et `nb_exemplaires` (disponibilité), tables `reservation` et `reservation_vehicule` (demandes des clients).
- Les clés étrangères composées (id, id_hotel) garantissent qu'une cotation ou une réservation ne mélange pas les éléments de deux hôtels.
