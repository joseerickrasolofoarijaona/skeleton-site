from django.shortcuts import get_object_or_404, render

from .cotation import CotationError, calculer_cotation
from .disponibilite import verifier
from .forms_cotation import CotationHotelForm
from .models import (
    Hotel, HotelEquipement, Saison, SupplementPension, Tarif, TypeChambre)


def detail_hotel(request, pk):
    hotel = get_object_or_404(Hotel, pk=pk, actif=True)

    chambres = list(
        TypeChambre.objects.filter(hotel=hotel).order_by("capacite", "libelle"))
    saisons = list(Saison.objects.filter(hotel=hotel).order_by("date_debut"))
    supplements = list(
        SupplementPension.objects.filter(hotel=hotel).order_by("prix_supplement"))
    equipements = sorted(
        lien.equipement.libelle
        for lien in HotelEquipement.objects.filter(hotel=hotel).select_related("equipement"))

    prix = {
        (t.type_chambre_id, t.saison_id): t.prix_nuitee
        for t in Tarif.objects.filter(type_chambre__hotel=hotel)}
    grille = [
        {"chambre": c, "prix": [prix.get((c.id, s.id)) for s in saisons]}
        for c in chambres]

    # Le formulaire est lu seulement si l'utilisateur a lancé un calcul
    lance = any(k in request.GET for k in ("type_chambre", "arrivee", "depart"))
    form = CotationHotelForm(hotel, request.GET) if lance else CotationHotelForm(hotel)

    resultat = None
    if lance and form.is_valid():
        d = form.cleaned_data
        try:
            resultat = calculer_cotation(
                d["type_chambre"], d["arrivee"], d["depart"],
                d["nb_chambres"], d["pension"])
            resultat.update(
                chambre=d["type_chambre"], arrivee=d["arrivee"], depart=d["depart"])
            resultat["dispo"] = verifier(
                d["type_chambre"], d["arrivee"], d["depart"], d["nb_chambres"])
        except CotationError as e:
            form.add_error(None, str(e))

    return render(request, "hotels/detail.html", {
        "hotel": hotel, "equipements": equipements, "saisons": saisons,
        "grille": grille, "supplements": supplements,
        "form": form, "resultat": resultat})
