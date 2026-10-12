from django.contrib.auth.forms import AuthenticationForm
from django.core.exceptions import ValidationError


class FormulaireConnexion(AuthenticationForm):
    """Seuls les comptes de l'équipe (is_staff) peuvent entrer."""

    def confirm_login_allowed(self, user):
        super().confirm_login_allowed(user)
        if not user.is_staff:
            raise ValidationError(
                "Ce compte n'a pas accès à l'espace de gestion.",
                code="acces_refuse",
            )
