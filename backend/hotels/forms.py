from django import forms
from django.core.exceptions import ValidationError
from django.db import connections, transaction

from .models import Equipement, Hotel

CATEGORIES = [("", "Non précisée"), ("1 étoile", "1 étoile")] + [
    (f"{n} étoiles", f"{n} étoiles") for n in range(2, 6)
]


class HotelForm(forms.ModelForm):
    categorie = forms.ChoiceField(
        choices=CATEGORIES, required=False, label="Catégorie")
    equipements = forms.ModelMultipleChoiceField(
        queryset=Equipement.objects.all(), required=False,
        widget=forms.CheckboxSelectMultiple, label="Équipements")

    class Meta:
        model = Hotel
        fields = ["nom", "localisation", "categorie", "contact", "remarques"]
        labels = {
            "nom": "Nom de l'hôtel",
            "localisation": "Destination",
            "contact": "Contact (téléphone ou e-mail)",
            "remarques": "Remarques",
        }
        widgets = {"remarques": forms.Textarea(attrs={"rows": 4})}

    def clean_categorie(self):
        return self.cleaned_data.get("categorie") or None

    def clean(self):
        data = super().clean()
        nom = (data.get("nom") or "").strip()
        localisation = (data.get("localisation") or "").strip()
        if nom and localisation:
            doublons = Hotel.objects.filter(
                nom__iexact=nom, localisation__iexact=localisation)
            if self.instance.pk:
                doublons = doublons.exclude(pk=self.instance.pk)
            if doublons.exists():
                raise ValidationError(
                    "Un hôtel avec ce nom existe déjà dans cette destination.")
        return data

    def enregistrer(self):
        """Enregistre l'hôtel et ses équipements en une seule opération."""
        with transaction.atomic(using="hotels"):
            hotel = self.save()
            ids = [e.id for e in self.cleaned_data["equipements"]]
            with connections["hotels"].cursor() as cur:
                cur.execute(
                    "DELETE FROM hotel_equipement WHERE id_hotel = %s",
                    [hotel.id])
                if ids:
                    cur.executemany(
                        "INSERT INTO hotel_equipement (id_hotel, id_equipement) "
                        "VALUES (%s, %s)",
                        [(hotel.id, i) for i in ids])
        return hotel
