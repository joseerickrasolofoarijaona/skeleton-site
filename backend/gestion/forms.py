from django import forms
from django.contrib.auth.forms import AuthenticationForm
from django.core.exceptions import ValidationError

from .models import Parametres


class FormulaireConnexion(AuthenticationForm):
    """Seuls les comptes de l'équipe (is_staff) peuvent entrer."""

    def confirm_login_allowed(self, user):
        super().confirm_login_allowed(user)
        if not user.is_staff:
            raise ValidationError(
                "Ce compte n'a pas accès à l'espace de gestion.",
                code="acces_refuse",
            )


class ParametresForm(forms.ModelForm):
    taux_eur_mga = forms.DecimalField(
        min_value=1, max_value=100000, max_digits=10, decimal_places=2,
        label="1 € vaut (en Ariary)")

    class Meta:
        model = Parametres
        fields = ["taux_eur_mga"]
