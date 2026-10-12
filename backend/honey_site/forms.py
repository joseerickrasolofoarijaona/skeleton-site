from django import forms
from django.core.exceptions import ValidationError
from django.core.validators import RegexValidator


class ReservationClientForm(forms.Form):
    nom = forms.CharField(label="Nom et prénom", max_length=150)
    email = forms.EmailField(label="Adresse e-mail", max_length=150)
    telephone = forms.CharField(
        label="Téléphone", max_length=30, required=False,
        validators=[RegexValidator(
            r"^[0-9+()./\- ]{6,30}$", "Numéro de téléphone invalide.")])
    nb_personnes = forms.IntegerField(
        label="Nombre de personnes", min_value=1, max_value=200)
    message = forms.CharField(
        label="Message (facultatif)", max_length=1000, required=False,
        widget=forms.Textarea(attrs={"rows": 4}))
    # Champ piège contre les robots : un humain ne le voit pas
    site_web = forms.CharField(
        required=False, label="Ne pas remplir",
        widget=forms.TextInput(attrs={"tabindex": "-1", "autocomplete": "off"}))

    def clean_nom(self):
        nom = self.cleaned_data["nom"].strip()
        if len(nom) < 2:
            raise ValidationError("Veuillez indiquer votre nom.")
        return nom

    def clean_site_web(self):
        if self.cleaned_data.get("site_web"):
            raise ValidationError("Envoi refusé.")
        return ""
