from decimal import Decimal, InvalidOperation, ROUND_HALF_UP

from django import template
from django.utils.html import format_html

register = template.Library()
ESPACE = "\u202f"


def _ariary(valeur):
    n = Decimal(valeur).quantize(Decimal("1"), rounding=ROUND_HALF_UP)
    return f"{int(n):,}".replace(",", ESPACE) + " Ar"


def _euros(valeur, taux):
    e = (Decimal(valeur) / Decimal(taux)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    entier, _, decimales = f"{e:.2f}".partition(".")
    return "≈ " + f"{int(entier):,}".replace(",", ESPACE) + f",{decimales} €"


@register.simple_tag(takes_context=True)
def prix(context, valeur, suffixe=""):
    """Affiche un montant en Ariary (MGA) et son équivalent en euros."""
    if valeur in (None, ""):
        return "—"
    try:
        ariary = _ariary(valeur)
    except (InvalidOperation, ValueError, TypeError):
        return "—"
    taux = context.get("taux_eur")
    if not taux:
        return format_html("{}{}", ariary, suffixe)
    return format_html(
        '<span class="prix">{}{}<small class="eur">{}</small></span>',
        ariary, suffixe, _euros(valeur, taux))
