"""Modèles de la base honey_hotels (tables créées par database/schema_complet.sql).

managed = False : Django ne touche pas à la structure des tables.
"""
from django.db import models


class Hotel(models.Model):
    nom = models.CharField(max_length=150)
    localisation = models.CharField(max_length=150)
    categorie = models.CharField(max_length=50, null=True, blank=True)
    contact = models.CharField(max_length=150, null=True, blank=True)
    remarques = models.TextField(null=True, blank=True)
    actif = models.BooleanField(default=True)

    class Meta:
        managed = False
        db_table = "hotel"
        ordering = ["nom"]

    def __str__(self):
        return f"{self.nom} ({self.localisation})"


class Equipement(models.Model):
    libelle = models.CharField(max_length=100, unique=True)

    class Meta:
        managed = False
        db_table = "equipement"
        ordering = ["libelle"]

    def __str__(self):
        return self.libelle


class HotelEquipement(models.Model):
    """Liaison hôtel <-> équipement (clé primaire composée)."""
    pk = models.CompositePrimaryKey("hotel", "equipement")
    hotel = models.ForeignKey(
        Hotel, on_delete=models.DO_NOTHING, db_column="id_hotel",
        related_name="hotel_equipements")
    equipement = models.ForeignKey(
        Equipement, on_delete=models.DO_NOTHING, db_column="id_equipement",
        related_name="hotel_equipements")

    class Meta:
        managed = False
        db_table = "hotel_equipement"


class TypeChambre(models.Model):
    hotel = models.ForeignKey(
        Hotel, on_delete=models.DO_NOTHING, db_column="id_hotel",
        related_name="types_chambre")
    libelle = models.CharField(max_length=100)
    capacite = models.PositiveSmallIntegerField()

    class Meta:
        managed = False
        db_table = "type_chambre"

    def __str__(self):
        return f"{self.libelle} - {self.hotel.nom}"


class Saison(models.Model):
    hotel = models.ForeignKey(
        Hotel, on_delete=models.DO_NOTHING, db_column="id_hotel",
        related_name="saisons")
    libelle = models.CharField(max_length=100)
    date_debut = models.DateField()
    date_fin = models.DateField()

    class Meta:
        managed = False
        db_table = "saison"

    def __str__(self):
        return f"{self.libelle} - {self.hotel.nom}"


class Tarif(models.Model):
    type_chambre = models.ForeignKey(
        TypeChambre, on_delete=models.DO_NOTHING, db_column="id_type_chambre",
        related_name="tarifs")
    saison = models.ForeignKey(
        Saison, on_delete=models.DO_NOTHING, db_column="id_saison",
        related_name="tarifs")
    prix_nuitee = models.DecimalField(max_digits=12, decimal_places=2)

    class Meta:
        managed = False
        db_table = "tarif"


class SupplementPension(models.Model):
    hotel = models.ForeignKey(
        Hotel, on_delete=models.DO_NOTHING, db_column="id_hotel",
        related_name="supplements_pension")
    type_pension = models.CharField(max_length=50)
    prix_supplement = models.DecimalField(max_digits=12, decimal_places=2)

    class Meta:
        managed = False
        db_table = "supplement_pension"

    def __str__(self):
        return f"{self.type_pension} - {self.hotel.nom}"


class Cotation(models.Model):
    hotel = models.ForeignKey(
        Hotel, on_delete=models.DO_NOTHING, db_column="id_hotel",
        related_name="cotations")
    type_chambre = models.ForeignKey(
        TypeChambre, on_delete=models.DO_NOTHING, db_column="id_type_chambre",
        related_name="cotations")
    saison = models.ForeignKey(
        Saison, on_delete=models.DO_NOTHING, db_column="id_saison",
        related_name="cotations")
    supplement_pension = models.ForeignKey(
        SupplementPension, on_delete=models.DO_NOTHING,
        db_column="id_supplement_pension", null=True, blank=True,
        related_name="cotations")
    nombre_nuits = models.PositiveSmallIntegerField()
    total_calcule = models.DecimalField(max_digits=14, decimal_places=2)

    class Meta:
        managed = False
        db_table = "cotation"
