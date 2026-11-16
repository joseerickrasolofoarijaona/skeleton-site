from django import forms
from django.core.exceptions import ValidationError
from django.db import connections, transaction

from .models import CategorieHotel, Destination, Equipement, Hotel


class HotelForm(forms.ModelForm):
    localisation = forms.ChoiceField(required=False, label="Destination")
    nouvelle_destination = forms.CharField(
        required=False, max_length=150,
        label="Ou nouvelle destination (si elle n'est pas dans la liste)")
    categorie = forms.ChoiceField(required=False, label="Catégorie")
    equipements = forms.ModelMultipleChoiceField(
        queryset=Equipement.objects.all(), required=False,
        widget=forms.CheckboxSelectMultiple, label="Équipements")

    field_order = ["nom", "localisation", "nouvelle_destination", "categorie",
                   "contact", "remarques", "equipements"]

    class Meta:
        model = Hotel
        fields = ["nom", "localisation", "categorie", "contact", "remarques"]
        labels = {
            "nom": "Nom de l'hôtel",
            "contact": "Contact (téléphone ou e-mail)",
            "remarques": "Remarques",
        }
        widgets = {"remarques": forms.Textarea(attrs={"rows": 4})}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["localisation"].choices = (
            [("", "Choisir une destination")]
            + [(d.nom, d.nom) for d in Destination.objects.order_by("nom")])
        self.fields["categorie"].choices = (
            [("", "Non précisée")]
            + [(c.libelle, c.libelle) for c in CategorieHotel.objects.all()])
        self._nouvelle_destination = ""

    def clean_categorie(self):
        return self.cleaned_data.get("categorie") or None

    def clean(self):
        data = super().clean()
        nouvelle = " ".join((data.get("nouvelle_destination") or "").split())
        if nouvelle:
            data["localisation"] = nouvelle
        self._nouvelle_destination = nouvelle

        nom = (data.get("nom") or "").strip()
        localisation = (data.get("localisation") or "").strip()
        if not localisation:
            self.add_error(
                "localisation",
                "Choisissez une destination ou saisissez-en une nouvelle.")
        elif nom:
            doublons = Hotel.objects.filter(
                nom__iexact=nom, localisation__iexact=localisation)
            if self.instance.pk:
                doublons = doublons.exclude(pk=self.instance.pk)
            if doublons.exists():
                raise ValidationError(
                    "Un hôtel avec ce nom existe déjà dans cette destination.")
        return data

    def enregistrer(self):
        """Enregistre l'hôtel, sa destination éventuelle et ses équipements."""
        with transaction.atomic(using="hotels"):
            if self._nouvelle_destination:
                dest, _ = Destination.objects.get_or_create(
                    nom=self._nouvelle_destination)
                self.instance.localisation = dest.nom
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
