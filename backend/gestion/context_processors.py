from decimal import Decimal

from .models import Parametres

TAUX_PROVISOIRE = Decimal("5000")


def monnaie(request):
    """Met le taux de change à disposition de toutes les pages."""
    try:
        p = Parametres.objects.filter(pk=1).first()
    except Exception:           # table pas encore créée : ne casse jamais la page
        p = None
    return {
        "taux_eur": p.taux_eur_mga if p else TAUX_PROVISOIRE,
        "taux_maj": p.mis_a_jour if p else None,
        "taux_defini": bool(p and p.defini),
    }
