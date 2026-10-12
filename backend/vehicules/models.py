"""Modèles de la base honey_vehicules (tables déjà créées par honey_vehicules.sql).

managed = False : Django ne touche pas à la structure des tables.
"""
from django.db import models


class Loueur(models.Model):
    nom = models.CharField(max_length=150, unique=True)
    telephone = models.CharField(max_length=50, null=True, blank=True)
    email = models.CharField(max_length=150, null=True, blank=True)
    localisation = models.CharField(max_length=150, null=True, blank=True)
    remarques = models.TextField(null=True, blank=True)
    actif = models.BooleanField(default=True)

    class Meta:
        managed = False
        db_table = "loueur"
        ordering = ["nom"]

    def __str__(self):
        return self.nom


class Vehicule(models.Model):
    loueur = models.ForeignKey(
        Loueur, on_delete=models.DO_NOTHING, db_column="id_loueur",
        related_name="vehicules")
    modele = models.CharField(max_length=100)
    categorie = models.CharField(max_length=50)
    capacite_passagers = models.PositiveSmallIntegerField()
    nb_exemplaires = models.PositiveSmallIntegerField(default=1)
    climatisation = models.BooleanField(default=False)
    remarques = models.TextField(null=True, blank=True)
    actif = models.BooleanField(default=True)

    class Meta:
        managed = False
        db_table = "vehicule"
        ordering = ["loueur__nom", "modele"]

    def __str__(self):
        return f"{self.modele} ({self.loueur.nom})"


class SaisonVehicule(models.Model):
    loueur = models.ForeignKey(
        Loueur, on_delete=models.DO_NOTHING, db_column="id_loueur",
        related_name="saisons")
    libelle = models.CharField(max_length=100)
    date_debut = models.DateField()
    date_fin = models.DateField()

    class Meta:
        managed = False
        db_table = "saison_vehicule"

    def __str__(self):
        return f"{self.libelle} - {self.loueur.nom}"


class TarifVehicule(models.Model):
    vehicule = models.ForeignKey(
        Vehicule, on_delete=models.DO_NOTHING, db_column="id_vehicule",
        related_name="tarifs")
    saison = models.ForeignKey(
        SaisonVehicule, on_delete=models.DO_NOTHING,
        db_column="id_saison_vehicule", related_name="tarifs")
    prix_journalier = models.DecimalField(max_digits=12, decimal_places=2)
    inclus_chauffeur = models.BooleanField(default=False)

    class Meta:
        managed = False
        db_table = "tarif_vehicule"


class CotationVehicule(models.Model):
    vehicule = models.ForeignKey(
        Vehicule, on_delete=models.DO_NOTHING, db_column="id_vehicule",
        related_name="cotations")
    saison = models.ForeignKey(
        SaisonVehicule, on_delete=models.DO_NOTHING,
        db_column="id_saison_vehicule", related_name="cotations")
    inclus_chauffeur = models.BooleanField(default=False)
    nombre_jours = models.PositiveSmallIntegerField()
    nombre_vehicules = models.PositiveSmallIntegerField(default=1)
    total_calcule = models.DecimalField(max_digits=14, decimal_places=2)

    class Meta:
        managed = False
        db_table = "cotation_vehicule"


class ReservationVehicule(models.Model):
    """Demande de location de véhicule (table reservation_vehicule)."""
    STATUTS = [
        ("en_attente", "En attente"),
        ("confirmee", "Confirmée"),
        ("refusee", "Refusée"),
        ("annulee", "Annulée"),
    ]
    reference = models.CharField(max_length=20, unique=True)
    vehicule = models.ForeignKey(
        Vehicule, on_delete=models.DO_NOTHING, db_column="id_vehicule",
        related_name="reservations")
    date_debut = models.DateField()
    date_fin = models.DateField()
    avec_chauffeur = models.BooleanField(default=False)
    nb_vehicules = models.PositiveSmallIntegerField(default=1)
    nb_personnes = models.PositiveSmallIntegerField()
    nom_client = models.CharField(max_length=150)
    email_client = models.EmailField(max_length=150)
    telephone_client = models.CharField(max_length=50, null=True, blank=True)
    message = models.TextField(null=True, blank=True)
    total_estime = models.DecimalField(max_digits=14, decimal_places=2)
    detail = models.TextField()
    statut = models.CharField(max_length=20, choices=STATUTS, default="en_attente")
    note_equipe = models.TextField(null=True, blank=True)
    cree_le = models.DateTimeField(auto_now_add=True)
    modifie_le = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = "reservation_vehicule"
        ordering = ["-cree_le"]

    def __str__(self):
        return f"{self.reference} - {self.nom_client}"
