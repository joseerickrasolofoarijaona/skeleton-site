from datetime import date

from django import forms

from .models import SupplementPension, TypeChambre


def champ_date():
    return forms.DateInput(attrs={"type": "date"}, format="%Y-%m-%d")


class CotationHotelForm(forms.Form):
    type_chambre = forms.ModelChoiceField(
        queryset=TypeChambre.objects.none(),
        label="Type de chambre", empty_label="Choisir une chambre")
    arrivee = forms.DateField(label="Arrivée", widget=champ_date())
    depart = forms.DateField(label="Départ", widget=champ_date())
    nb_chambres = forms.IntegerField(
        label="Nombre de chambres", min_value=1, max_value=20, initial=1)
    pension = forms.ModelChoiceField(
        queryset=SupplementPension.objects.none(), required=False,
        label="Formule de pension", empty_label="Logement seul (sans pension)")

    def __init__(self, hotel, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["type_chambre"].queryset = (
            TypeChambre.objects.filter(hotel=hotel).order_by("capacite", "libelle"))
        self.fields["pension"].queryset = (
            SupplementPension.objects.filter(hotel=hotel).order_by("prix_supplement"))
        self.fields["type_chambre"].label_from_instance = (
            lambda o: f"{o.libelle} ({o.capacite} pers.)")
        self.fields["pension"].label_from_instance = (
            lambda o: f"{o.type_pension} (+{int(o.prix_supplement):,} Ar/nuit)".replace(",", " "))
        aujourdhui = date.today().isoformat()
        self.fields["arrivee"].widget.attrs["min"] = aujourdhui
        self.fields["depart"].widget.attrs["min"] = aujourdhui

    def clean(self):
        data = super().clean()
        arrivee, depart = data.get("arrivee"), data.get("depart")
        if arrivee and arrivee < date.today():
            self.add_error("arrivee", "La date d'arrivée ne peut pas être dans le passé.")
        if arrivee and depart and depart <= arrivee:
            self.add_error("depart", "Le départ doit être après l'arrivée.")
        return data
