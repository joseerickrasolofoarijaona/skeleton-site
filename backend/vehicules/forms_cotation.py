from datetime import date

from django import forms


def champ_date():
    return forms.DateInput(attrs={"type": "date"}, format="%Y-%m-%d")


class CotationVehiculeForm(forms.Form):
    debut = forms.DateField(label="Début de location", widget=champ_date())
    fin = forms.DateField(label="Fin de location", widget=champ_date())
    chauffeur = forms.ChoiceField(
        label="Chauffeur", initial="1", widget=forms.RadioSelect,
        choices=[("1", "Avec chauffeur"), ("0", "Sans chauffeur")])
    nb_vehicules = forms.IntegerField(
        label="Nombre de véhicules", min_value=1, max_value=20, initial=1)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        aujourdhui = date.today().isoformat()
        self.fields["debut"].widget.attrs["min"] = aujourdhui
        self.fields["fin"].widget.attrs["min"] = aujourdhui

    def clean(self):
        data = super().clean()
        debut, fin = data.get("debut"), data.get("fin")
        if debut and debut < date.today():
            self.add_error("debut", "Le début ne peut pas être dans le passé.")
        if debut and fin and fin < debut:
            self.add_error("fin", "La fin doit être le même jour ou après le début.")
        return data
