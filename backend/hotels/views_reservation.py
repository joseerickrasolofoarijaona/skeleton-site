import logging

from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse

from honey_site.emails import (
    corps_accuse, corps_demande, envoyer_client, notifier_equipe)
from honey_site.forms import ReservationClientForm
from honey_site.outils import limiter_demandes

from .cotation import CotationError, calculer_cotation
from .disponibilite import verifier
from .forms_cotation import CotationHotelForm
from .models import Hotel
from .reservation import construire_instantane, creer_reservation

logger = logging.getLogger(__name__)

CLES = ("type_chambre", "arrivee", "depart", "nb_chambres", "pension")


def reserver_hotel(request, pk):
    hotel = get_object_or_404(Hotel, pk=pk, actif=True)
    source = request.POST if request.method == "POST" else request.GET
    contexte = {
        "retour": reverse("hotels:detail", args=[hotel.pk]),
        "genre": "hôtel",
    }

    if not all(source.get(k) for k in ("type_chambre", "arrivee", "depart")):
        contexte["erreur"] = ("Choisissez d'abord une chambre et des dates, "
                              "puis lancez le calcul du prix.")
        return render(request, "reservation/formulaire.html", contexte)

    cot_form = CotationHotelForm(hotel, source)
    if not cot_form.is_valid():
        contexte["erreur"] = "Votre sélection n'est pas valide : " + " ".join(
            m for errs in cot_form.errors.values() for m in errs)
        return render(request, "reservation/formulaire.html", contexte)

    d = cot_form.cleaned_data
    try:
        resultat = calculer_cotation(
            d["type_chambre"], d["arrivee"], d["depart"],
            d["nb_chambres"], d["pension"])
    except CotationError as e:
        contexte["erreur"] = str(e)
        return render(request, "reservation/formulaire.html", contexte)

    dispo = verifier(d["type_chambre"], d["arrivee"], d["depart"], d["nb_chambres"])
    if not dispo["disponible"]:
        contexte["erreur"] = dispo["message"]
        return render(request, "reservation/formulaire.html", contexte)

    instantane = construire_instantane(hotel, d, resultat)
    capacite_max = d["type_chambre"].capacite * d["nb_chambres"]
    client_form = ReservationClientForm(
        request.POST or None, initial={"nb_personnes": capacite_max})

    if request.method == "POST" and client_form.is_valid():
        c = client_form.cleaned_data
        if c["nb_personnes"] > capacite_max:
            client_form.add_error(
                "nb_personnes",
                f"Cette sélection accueille au maximum {capacite_max} personne(s).")
        elif limiter_demandes(request):
            client_form.add_error(
                None, "Vous avez envoyé trop de demandes en peu de temps. "
                      "Veuillez réessayer dans une heure ou nous contacter directement.")
        else:
            try:
                reservation = creer_reservation(hotel, d, c, resultat, instantane)
            except Exception:
                logger.exception("Création de la réservation d'hôtel impossible")
                client_form.add_error(
                    None, "Votre demande n'a pas pu être enregistrée. "
                          "Veuillez réessayer ou nous contacter.")
            else:
                notifier_equipe(
                    f"[Honey Group] Demande de réservation {reservation.reference} - {hotel.nom}",
                    corps_demande(reservation, instantane),
                    reply_to=c["email"])
                envoyer_client(
                    c["email"],
                    f"[Honey Group] Nous avons bien reçu votre demande {reservation.reference}",
                    corps_accuse(reservation, instantane))
                return redirect("confirmation", reference=reservation.reference)

    contexte.update(
        instantane=instantane,
        client_form=client_form,
        champs_caches=[(k, source.get(k, "")) for k in CLES],
        capacite_max=capacite_max,
    )
    return render(request, "reservation/formulaire.html", contexte)
