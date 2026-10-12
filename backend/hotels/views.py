from django.db.models import Min
from django.shortcuts import render

from .models import Equipement, Hotel, HotelEquipement


def enrichir_hotels(queryset):
    """Ajoute à chaque hôtel son prix minimum et la liste de ses équipements."""
    hotels = list(
        queryset.annotate(prix_min=Min("types_chambre__tarifs__prix_nuitee"))
    )
    liens = HotelEquipement.objects.filter(
        hotel_id__in=[h.id for h in hotels]
    ).select_related("equipement")
    par_hotel = {}
    for lien in liens:
        par_hotel.setdefault(lien.hotel_id, []).append(lien.equipement.libelle)
    for h in hotels:
        h.liste_equipements = sorted(par_hotel.get(h.id, []))
    return hotels


def liste_hotels(request):
    """Recherche multicritères : destination, catégorie, équipements."""
    destination = request.GET.get("destination", "").strip()
    categorie = request.GET.get("categorie", "").strip()
    equip_ids = [int(i) for i in request.GET.getlist("equipement") if i.isdigit()]

    hotels = Hotel.objects.filter(actif=True)

    if destination:
        hotels = hotels.filter(localisation=destination)
    if categorie:
        hotels = hotels.filter(categorie=categorie)
    # Un filtre par équipement coché : l'hôtel doit tous les avoir
    for equip_id in equip_ids:
        hotels = hotels.filter(hotel_equipements__equipement_id=equip_id)

    actifs = Hotel.objects.filter(actif=True)
    destinations = (
        actifs.order_by("localisation")
        .values_list("localisation", flat=True).distinct()
    )
    categories = (
        actifs.filter(categorie__isnull=False).order_by("categorie")
        .values_list("categorie", flat=True).distinct()
    )

    return render(request, "hotels/liste.html", {
        "hotels": enrichir_hotels(hotels),
        "destinations": destinations,
        "categories": categories,
        "equipements": Equipement.objects.all(),
        "destination": destination,
        "categorie": categorie,
        "equip_ids": equip_ids,
    })
