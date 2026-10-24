from decimal import Decimal

from django.db import models


class Parametres(models.Model):
    """Réglages de l'application (une seule ligne, pk=1).

    Stockés dans la petite base interne de Django (SQLite), et non dans les
    deux bases Honey, qui restent indépendantes.
    """
    taux_eur_mga = models.DecimalField(
        "1 € vaut (en Ariary)", max_digits=10, decimal_places=2,
        default=Decimal("5000"))
    defini = models.BooleanField(default=False, editable=False)
    mis_a_jour = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "paramètres"
        verbose_name_plural = "paramètres"
