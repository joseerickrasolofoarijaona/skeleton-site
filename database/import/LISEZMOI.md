# Import de tarifs depuis des fichiers CSV

1. Recopiez un des modèles `modele_*.csv` et remplacez les lignes d'exemple par vos données (une ligne = un tarif).
   Enregistrez en **CSV UTF-8, séparateur point-virgule** (c'est le format d'Excel en français).
2. Dates : AAAA-MM-JJ ou JJ/MM/AAAA. Montants : en **Ariary (MGA)**, sans symbole.
   Équipements : séparés par une barre verticale (`Piscine|Wi-Fi`). `avec_chauffeur` et `climatisation` : oui ou non.
3. Les destinations, catégories d'hôtel et types de véhicule doivent exister dans les listes de référence.
4. Depuis `backend/`, avec l'environnement activé, testez d'abord sans rien enregistrer :

        python ../database/import/importer.py hotels_tarifs ../database/import/mon_fichier.csv --simulation

5. Si la simulation réussit, relancez la même commande **sans** `--simulation`.

Ordre conseillé pour les hôtels : d'abord `hotels_tarifs`, puis `hotels_pensions`.
Si une seule ligne est invalide, **rien n'est enregistré** et le script indique les lignes à corriger.
Relancer l'import d'un même fichier met à jour les données sans créer de doublons.
