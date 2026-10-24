from django import forms
from django.core.exceptions import ValidationError
from django.db.models import Q

from .models import Loueur, Vehicule

TYPES = ["4x4", "Minibus", "Berline", "Autocar"]


class LoueurForm(forms.ModelForm):
    email = forms.EmailField(required=False, empty_value=None, label="E-mail")

    class Meta:
        model = Loueur
        fields = ["nom", "telephone", "email", "localisation", "remarques"]
        labels = {
            "nom": "Nom du loueur",
            "telephone": "Téléphone",
            "localisation": "Ville",
            "remarques": "Remarques",
        }
        widgets = {"remarques": forms.Textarea(attrs={"rows": 4})}

    def clean_nom(self):
        nom = self.cleaned_data["nom"].strip()
        doublons = Loueur.objects.filter(nom__iexact=nom)
        if self.instance.pk:
            doublons = doublons.exclude(pk=self.instance.pk)
        if doublons.exists():
            raise ValidationError("Un loueur avec ce nom existe déjà.")
        return nom


class VehiculeForm(forms.ModelForm):
    categorie = forms.ChoiceField(label="Type de véhicule")
    capacite_passagers = forms.IntegerField(
        min_value=1, max_value=100, label="Nombre de places")

    class Meta:
        model = Vehicule
        fields = ["loueur", "modele", "categorie", "capacite_passagers",
                  "climatisation", "remarques"]
        labels = {
            "loueur": "Loueur",
            "modele": "Modèle",
            "climatisation": "Climatisation",
            "remarques": "Remarques",
        }
        widgets = {"remarques": forms.Textarea(attrs={"rows": 4})}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Seuls les loueurs en service (plus le loueur actuel en modification)
        actuel = self.instance.loueur_id if self.instance.pk else None
        self.fields["loueur"].queryset = Loueur.objects.filter(
            Q(actif=True) | Q(pk=actuel))
        self.fields["loueur"].empty_label = "Choisir un loueur"

        types = list(TYPES)
        if self.instance.pk and self.instance.categorie not in types:
            types.append(self.instance.categorie)
        self.fields["categorie"].choices = (
            [("", "Choisir un type")] + [(t, t) for t in types])

    def clean(self):
        data = super().clean()
        loueur = data.get("loueur")
        modele = (data.get("modele") or "").strip()
        if loueur and modele:
            doublons = Vehicule.objects.filter(
                loueur=loueur, modele__iexact=modele)
            if self.instance.pk:
                doublons = doublons.exclude(pk=self.instance.pk)
            if doublons.exists():
                raise ValidationError(
                    "Ce loueur a déjà un véhicule avec ce modèle.")
            data["modele"] = modele
        return data
