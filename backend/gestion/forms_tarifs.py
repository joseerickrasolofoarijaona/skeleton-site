from django import forms
from django.core.exceptions import ValidationError
from django.forms import modelformset_factory

from hotels.models import Saison, SupplementPension, TypeChambre
from vehicules.models import SaisonVehicule


def champ_date():
    return forms.DateInput(attrs={"type": "date"}, format="%Y-%m-%d")


class SaisonBaseForm(forms.ModelForm):
    def clean(self):
        data = super().clean()
        debut, fin = data.get("date_debut"), data.get("date_fin")
        if debut and fin and fin < debut:
            raise ValidationError("La date de fin doit être après la date de début.")
        return data


class SaisonHotelForm(SaisonBaseForm):
    class Meta:
        model = Saison
        fields = ["libelle", "date_debut", "date_fin"]
        labels = {"libelle": "Saison", "date_debut": "Début", "date_fin": "Fin"}
        widgets = {"date_debut": champ_date(), "date_fin": champ_date()}


class SaisonVehiculeForm(SaisonBaseForm):
    class Meta:
        model = SaisonVehicule
        fields = ["libelle", "date_debut", "date_fin"]
        labels = {"libelle": "Saison", "date_debut": "Début", "date_fin": "Fin"}
        widgets = {"date_debut": champ_date(), "date_fin": champ_date()}


class TypeChambreForm(forms.ModelForm):
    capacite = forms.IntegerField(
        min_value=1, max_value=50, label="Capacité (personnes)")
    nb_chambres = forms.IntegerField(
        min_value=0, max_value=1000, initial=1, label="Stock (chambres)")

    class Meta:
        model = TypeChambre
        fields = ["libelle", "capacite", "nb_chambres"]
        labels = {"libelle": "Type de chambre"}


class SupplementForm(forms.ModelForm):
    prix_supplement = forms.DecimalField(
        min_value=0, max_digits=12, decimal_places=2,
        label="Prix (Ar / nuit)")

    class Meta:
        model = SupplementPension
        fields = ["type_pension", "prix_supplement"]
        labels = {"type_pension": "Formule"}


TypeChambreFormSet = modelformset_factory(
    TypeChambre, form=TypeChambreForm, extra=1, can_delete=True)
SaisonHotelFormSet = modelformset_factory(
    Saison, form=SaisonHotelForm, extra=1, can_delete=True)
SupplementFormSet = modelformset_factory(
    SupplementPension, form=SupplementForm, extra=1, can_delete=True)
SaisonVehiculeFormSet = modelformset_factory(
    SaisonVehicule, form=SaisonVehiculeForm, extra=1, can_delete=True)
