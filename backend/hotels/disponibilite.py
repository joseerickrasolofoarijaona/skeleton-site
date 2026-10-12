"""Disponibilité des chambres : stock moins les réservations confirmées."""
from datetime import timedelta

from .models import Reservation


def verifier(type_chambre, arrivee, depart, nb_chambres, exclure_pk=None):
    """Contrôle nuit par nuit. La nuit de départ n'est pas comptée."""
    stock = type_chambre.nb_chambres
    qs = Reservation.objects.filter(
        type_chambre=type_chambre, statut="confirmee",
        arrivee__lt=depart, depart__gt=arrivee)
    if exclure_pk:
        qs = qs.exclude(pk=exclure_pk)
    resas = list(qs.values_list("arrivee", "depart", "nb_chambres"))

    libres_min = stock
    premiere_nuit = None
    libres_premiere = None
    for i in range((depart - arrivee).days):
        nuit = arrivee + timedelta(days=i)
        occupees = sum(n for a, d, n in resas if a <= nuit < d)
        libres = stock - occupees
        libres_min = min(libres_min, libres)
        if libres < nb_chambres and premiere_nuit is None:
            premiere_nuit, libres_premiere = nuit, max(libres, 0)
    libres_min = max(libres_min, 0)

    disponible = premiere_nuit is None
    if disponible:
        message = ""
        resume = (f"Disponible : {libres_min} chambre(s) libre(s) au minimum "
                  f"sur ces dates (stock : {stock}).")
    else:
        message = (f"Pas assez de chambres pour ces dates : il en reste "
                   f"{libres_premiere} la nuit du {premiere_nuit:%d/%m/%Y} pour "
                   f"{nb_chambres} demandée(s). Essayez d'autres dates ou contactez-nous.")
        resume = "Indisponible : " + message
    return {"disponible": disponible, "stock": stock, "libres": libres_min,
            "message": message, "resume": resume}
