"""Disponibilité des véhicules : exemplaires moins les réservations confirmées."""
from datetime import timedelta

from .models import ReservationVehicule


def verifier(vehicule, debut, fin, nb_vehicules, exclure_pk=None):
    """Contrôle jour par jour. Le premier et le dernier jour sont comptés."""
    stock = vehicule.nb_exemplaires
    qs = ReservationVehicule.objects.filter(
        vehicule=vehicule, statut="confirmee",
        date_debut__lte=fin, date_fin__gte=debut)
    if exclure_pk:
        qs = qs.exclude(pk=exclure_pk)
    resas = list(qs.values_list("date_debut", "date_fin", "nb_vehicules"))

    libres_min = stock
    premier_jour = None
    libres_premier = None
    for i in range((fin - debut).days + 1):
        jour = debut + timedelta(days=i)
        occupes = sum(n for a, d, n in resas if a <= jour <= d)
        libres = stock - occupes
        libres_min = min(libres_min, libres)
        if libres < nb_vehicules and premier_jour is None:
            premier_jour, libres_premier = jour, max(libres, 0)
    libres_min = max(libres_min, 0)

    disponible = premier_jour is None
    if disponible:
        message = ""
        resume = (f"Disponible : {libres_min} véhicule(s) libre(s) au minimum "
                  f"sur ces dates (stock : {stock}).")
    else:
        message = (f"Pas assez de véhicules pour ces dates : il en reste "
                   f"{libres_premier} le {premier_jour:%d/%m/%Y} pour "
                   f"{nb_vehicules} demandé(s). Essayez d'autres dates ou contactez-nous.")
        resume = "Indisponible : " + message
    return {"disponible": disponible, "stock": stock, "libres": libres_min,
            "message": message, "resume": resume}
