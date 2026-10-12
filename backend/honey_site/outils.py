import secrets

from django.conf import settings
from django.core.cache import cache

# Sans caractères ambigus (0/O, 1/I/L)
ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"


def nouvelle_reference(prefixe):
    """Référence aléatoire, impossible à deviner : HTL-7K3M9PQX."""
    return f"{prefixe}-" + "".join(secrets.choice(ALPHABET) for _ in range(8))


def masquer_email(email):
    local, _, domaine = (email or "").partition("@")
    return f"{local[:1]}***@{domaine}" if domaine else "***"


def date_fr(d):
    return d.strftime("%d/%m/%Y")


def limiter_demandes(request, fenetre=3600):
    """True si cette adresse IP a dépassé sa limite de demandes par heure."""
    maximum = getattr(settings, "RESERVATIONS_MAX_PAR_HEURE", 5)
    cle = "resa_" + request.META.get("REMOTE_ADDR", "inconnue")
    if cache.add(cle, 1, fenetre):
        return False
    try:
        return cache.incr(cle) > maximum
    except ValueError:                      # la clé vient d'expirer
        cache.set(cle, 1, fenetre)
        return False
