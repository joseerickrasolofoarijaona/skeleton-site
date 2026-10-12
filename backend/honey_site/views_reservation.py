import json

from django.http import Http404
from django.shortcuts import get_object_or_404, render

from hotels.models import Reservation
from vehicules.models import ReservationVehicule

from .outils import masquer_email


def confirmation(request, reference):
    """Page publique, accessible seulement avec la référence aléatoire."""
    ref = reference.strip().upper()
    if ref.startswith("HTL-"):
        r = get_object_or_404(
            Reservation.objects.select_related("hotel"), reference=ref)
        sujet, genre = r.hotel.nom, "hôtel"
    elif ref.startswith("VEH-"):
        r = get_object_or_404(
            ReservationVehicule.objects.select_related("vehicule"), reference=ref)
        sujet, genre = r.vehicule.modele, "véhicule"
    else:
        raise Http404

    try:
        instantane = json.loads(r.detail)
    except ValueError:
        instantane = {"recap": [], "lignes": [], "total": str(r.total_estime),
                      "multiplicateur": ""}

    return render(request, "reservation/confirmation.html", {
        "r": r, "instantane": instantane, "sujet": sujet, "genre": genre,
        "email_masque": masquer_email(r.email_client),
    })
