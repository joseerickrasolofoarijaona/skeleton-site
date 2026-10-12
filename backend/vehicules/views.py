from datetime import date

from django.db.models import Min
from django.shortcuts import render

from .models import Loueur, Vehicule


def lire_date(valeur):
    """Convertit '2026-08-15' en date, ou None si la valeur est vide ou fausse."""
    try:
        return date.fromisoformat(valeur)
    except (ValueError, TypeError):
        return None


def liste_vehicules(request):
    """Recherche multicritères : type, loueur, période."""
    categorie = request.GET.get("categorie", "").strip()
    loueur = request.GET.get("loueur", "").strip()
    debut = lire_date(request.GET.get("date_debut", ""))
    fin = lire_date(request.GET.get("date_fin", ""))
    erreur = None

    # Une seule date donnée : on cherche ce jour-là
    if debut and not fin:
        fin = debut
    if fin and not debut:
        debut = fin
    if debut and fin and debut > fin:
        erreur = "La date de fin doit être après la date de début."
        debut = fin = None

    vehicules = Vehicule.objects.filter(
        actif=True, loueur__actif=True
    ).select_related("loueur")

    if categorie:
        vehicules = vehicules.filter(categorie=categorie)
    if loueur.isdigit():
        vehicules = vehicules.filter(loueur_id=int(loueur))
    if debut and fin:
        # Le véhicule a un tarif sur une saison qui chevauche la période
        vehicules = vehicules.filter(
            tarifs__saison__date_debut__lte=fin,
            tarifs__saison__date_fin__gte=debut,
        )

    vehicules = list(
        vehicules.annotate(prix_min=Min("tarifs__prix_journalier"))
    )

    actifs = Vehicule.objects.filter(actif=True, loueur__actif=True)
    categories = (
        actifs.order_by("categorie")
        .values_list("categorie", flat=True).distinct()
    )

    return render(request, "vehicules/liste.html", {
        "vehicules": vehicules,
        "categories": categories,
        "loueurs": Loueur.objects.filter(actif=True),
        "categorie": categorie,
        "loueur": int(loueur) if loueur.isdigit() else None,
        "date_debut": request.GET.get("date_debut", ""),
        "date_fin": request.GET.get("date_fin", ""),
        "periode": bool(debut and fin),
        "erreur": erreur,
    })
