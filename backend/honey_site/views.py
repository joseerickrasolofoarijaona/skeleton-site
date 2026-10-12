from django.db.models import Min, Q
from django.shortcuts import render

from hotels.models import Hotel
from hotels.views import enrichir_hotels
from vehicules.models import Vehicule


def recherche_globale(request):
    """Cherche un ou plusieurs mots dans les hôtels ET les véhicules."""
    q = request.GET.get("q", "").strip()
    termes = q.split()

    hotels, vehicules = [], []

    if termes:
        qs_hotels = Hotel.objects.filter(actif=True)
        qs_vehicules = Vehicule.objects.filter(
            actif=True, loueur__actif=True
        ).select_related("loueur")

        # Chaque mot doit être trouvé quelque part (mots reliés par "ET")
        for terme in termes:
            qs_hotels = qs_hotels.filter(
                Q(nom__icontains=terme)
                | Q(localisation__icontains=terme)
                | Q(categorie__icontains=terme)
                | Q(remarques__icontains=terme)
                | Q(hotel_equipements__equipement__libelle__icontains=terme)
            )
            qs_vehicules = qs_vehicules.filter(
                Q(modele__icontains=terme)
                | Q(categorie__icontains=terme)
                | Q(remarques__icontains=terme)
                | Q(loueur__nom__icontains=terme)
                | Q(loueur__localisation__icontains=terme)
            )

        hotels = enrichir_hotels(qs_hotels)[:50]
        vehicules = list(
            qs_vehicules.annotate(prix_min=Min("tarifs__prix_journalier"))[:50]
        )

    return render(request, "recherche.html", {
        "q": q,
        "hotels": hotels,
        "vehicules": vehicules,
        "total": len(hotels) + len(vehicules),
    })
