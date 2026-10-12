import logging

from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse

from honey_site.emails import (
    corps_accuse, corps_demande, envoyer_client, notifier_equipe)
from honey_site.forms import ReservationClientForm
from honey_site.outils import limiter_demandes

from .cotation import CotationError, calculer_cotation
from .disponibilite import verifier
from .forms_cotation import CotationVehiculeForm
from .models import Vehicule
from .reservation import construire_instantane, creer_reservation

logger = logging.getLogger(__name__)

CLES = ("debut", "fin", "chauffeur", "nb_vehicules")


def reserver_vehicule(request, pk):
    vehicule = get_object_or_404(
        Vehicule.objects.select_related("loueur"),
        pk=pk, actif=True, loueur__actif=True)
    source = request.POST if request.method == "POST" else request.GET
    contexte = {
        "retour": reverse("vehicules:detail", args=[vehicule.pk]),
        "genre": "véhicule",
    }

    if not all(source.get(k) for k in ("debut", "fin", "chauffeur")):
        contexte["erreur"] = ("Choisissez d'abord des dates et une option chauffeur, "
                              "puis lancez le calcul du prix.")
        return render(request, "reservation/formulaire.html", contexte)

    cot_form = CotationVehiculeForm(source)
    if not cot_form.is_valid():
        contexte["erreur"] = "Votre sélection n'est pas valide : " + " ".join(
            m for errs in cot_form.errors.values() for m in errs)
        return render(request, "reservation/formulaire.html", contexte)

    d = cot_form.cleaned_data
    try:
        resultat = calculer_cotation(
            vehicule, d["debut"], d["fin"],
            d["chauffeur"] == "1", d["nb_vehicules"])
    except CotationError as e:
        contexte["erreur"] = str(e)
        return render(request, "reservation/formulaire.html", contexte)

    dispo = verifier(vehicule, d["debut"], d["fin"], d["nb_vehicules"])
    if not dispo["disponible"]:
        contexte["erreur"] = dispo["message"]
        return render(request, "reservation/formulaire.html", contexte)

    instantane = construire_instantane(vehicule, d, resultat)
    capacite_max = vehicule.capacite_passagers * d["nb_vehicules"]
    client_form = ReservationClientForm(
        request.POST or None, initial={"nb_personnes": capacite_max})

    if request.method == "POST" and client_form.is_valid():
        c = client_form.cleaned_data
        if c["nb_personnes"] > capacite_max:
            client_form.add_error(
                "nb_personnes",
                f"Cette sélection transporte au maximum {capacite_max} personne(s).")
        elif limiter_demandes(request):
            client_form.add_error(
                None, "Vous avez envoyé trop de demandes en peu de temps. "
                      "Veuillez réessayer dans une heure ou nous contacter directement.")
        else:
            try:
                reservation = creer_reservation(vehicule, d, c, resultat, instantane)
            except Exception:
                logger.exception("Création de la réservation de véhicule impossible")
                client_form.add_error(
                    None, "Votre demande n'a pas pu être enregistrée. "
                          "Veuillez réessayer ou nous contacter.")
            else:
                notifier_equipe(
                    f"[Honey Group] Demande de location {reservation.reference} - {vehicule.modele}",
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
