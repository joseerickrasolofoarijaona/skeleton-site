import json
from urllib.parse import urlencode

from django.contrib import messages
from django.core.paginator import Paginator
from django.db.models import Count, Q
from django.http import Http404
from django.shortcuts import redirect, render
from django.utils import timezone
from django.views.decorators.http import require_POST

from hotels.models import Hotel, Reservation
from vehicules.models import Loueur, ReservationVehicule, Vehicule

from honey_site.emails import corps_statut, envoyer_client
from honey_site.outils import masquer_email

from django.db import transaction
from hotels.models import TypeChambre

from .dispo import dispo_reservation
from .views import staff_required

STATUTS = dict(Reservation.STATUTS)

# action -> (nouveau statut, statuts de départ autorisés)
ACTIONS = {
    "confirmer": ("confirmee", {"en_attente"}),
    "refuser": ("refusee", {"en_attente"}),
    "annuler": ("annulee", {"en_attente", "confirmee"}),
}
MESSAGES_ACTION = {
    "confirmer": "confirmée",
    "refuser": "refusée",
    "annuler": "annulée",
}

CHAMPS_HOTEL = ("reference", "nom_client", "email_client", "hotel__nom")
CHAMPS_VEHICULE = ("reference", "nom_client", "email_client",
                   "vehicule__modele", "vehicule__loueur__nom")


# ---------------------------------------------------------------------
# Outils
# ---------------------------------------------------------------------
def ligne_hotel(r):
    return {
        "reference": r.reference, "genre": "hotel", "genre_label": "Hôtel",
        "sujet": r.hotel.nom,
        "periode": f"{r.arrivee:%d/%m/%Y} → {r.depart:%d/%m/%Y}",
        "client": r.nom_client, "total": r.total_estime,
        "statut": r.statut, "statut_label": r.get_statut_display(),
        "cree_le": r.cree_le,
    }


def ligne_vehicule(r):
    return {
        "reference": r.reference, "genre": "vehicule", "genre_label": "Véhicule",
        "sujet": r.vehicule.modele,
        "periode": f"{r.date_debut:%d/%m/%Y} → {r.date_fin:%d/%m/%Y}",
        "client": r.nom_client, "total": r.total_estime,
        "statut": r.statut, "statut_label": r.get_statut_display(),
        "cree_le": r.cree_le,
    }


def filtrer(qs, statut, q, champs):
    if statut in STATUTS:
        qs = qs.filter(statut=statut)
    for mot in q.split():
        cond = Q()
        for champ in champs:
            cond |= Q(**{f"{champ}__icontains": mot})
        qs = qs.filter(cond)
    return qs


def compter():
    comptes = {cle: 0 for cle in STATUTS}
    for modele in (Reservation, ReservationVehicule):
        for ligne in modele.objects.values("statut").annotate(n=Count("id")).order_by():
            comptes[ligne["statut"]] = comptes.get(ligne["statut"], 0) + ligne["n"]
    return comptes


def charger(reference):
    ref = reference.strip().upper()
    r = genre = None
    if ref.startswith("HTL-"):
        r = Reservation.objects.select_related("hotel").filter(reference=ref).first()
        genre = "hotel"
    elif ref.startswith("VEH-"):
        r = (ReservationVehicule.objects.select_related("vehicule__loueur")
             .filter(reference=ref).first())
        genre = "vehicule"
    if r is None:
        raise Http404
    return r, genre


# ---------------------------------------------------------------------
# Tableau de bord
# ---------------------------------------------------------------------
@staff_required
def tableau_de_bord(request):
    comptes = compter()
    recentes = []
    recentes += [ligne_hotel(r) for r in Reservation.objects
                 .select_related("hotel").filter(statut="en_attente")
                 .order_by("-cree_le")[:5]]
    recentes += [ligne_vehicule(r) for r in ReservationVehicule.objects
                 .select_related("vehicule").filter(statut="en_attente")
                 .order_by("-cree_le")[:5]]
    recentes.sort(key=lambda l: l["cree_le"], reverse=True)

    return render(request, "gestion/tableau_de_bord.html", {
        "section": "accueil",
        "hotels_actifs": Hotel.objects.filter(actif=True).count(),
        "hotels_archives": Hotel.objects.filter(actif=False).count(),
        "vehicules_actifs": Vehicule.objects.filter(actif=True).count(),
        "vehicules_archives": Vehicule.objects.filter(actif=False).count(),
        "loueurs_actifs": Loueur.objects.filter(actif=True).count(),
        "nb_en_attente": comptes["en_attente"],
        "nb_confirmees": comptes["confirmee"],
        "recentes": recentes[:5],
    })


# ---------------------------------------------------------------------
# Liste
# ---------------------------------------------------------------------
@staff_required
def liste(request):
    statut = request.GET.get("statut", "")
    if statut not in STATUTS:
        statut = ""
    genre = request.GET.get("type", "")
    if genre not in ("hotel", "vehicule"):
        genre = ""
    q = request.GET.get("q", "").strip()[:100]

    lignes = []
    if genre in ("", "hotel"):
        qs = filtrer(Reservation.objects.select_related("hotel"),
                     statut, q, CHAMPS_HOTEL)
        lignes += [ligne_hotel(r) for r in qs.order_by("-cree_le")[:500]]
    if genre in ("", "vehicule"):
        qs = filtrer(ReservationVehicule.objects.select_related("vehicule"),
                     statut, q, CHAMPS_VEHICULE)
        lignes += [ligne_vehicule(r) for r in qs.order_by("-cree_le")[:500]]
    lignes.sort(key=lambda l: l["cree_le"], reverse=True)

    page = Paginator(lignes, 20).get_page(request.GET.get("page"))

    comptes = compter()
    onglets = []
    for cle, libelle in [("", "Toutes"), ("en_attente", "En attente"),
                         ("confirmee", "Confirmées"), ("refusee", "Refusées"),
                         ("annulee", "Annulées")]:
        params = {k: v for k, v in {"statut": cle, "type": genre, "q": q}.items() if v}
        onglets.append({
            "libelle": libelle,
            "n": sum(comptes.values()) if cle == "" else comptes[cle],
            "actif": cle == statut,
            "url": "?" + urlencode(params),
        })

    base_qs = urlencode({k: v for k, v in
                         {"statut": statut, "type": genre, "q": q}.items() if v})
    return render(request, "gestion/reservations_liste.html", {
        "section": "reservations", "page": page, "onglets": onglets,
        "statut": statut, "genre": genre, "q": q, "base_qs": base_qs,
    })


# ---------------------------------------------------------------------
# Fiche d'une demande
# ---------------------------------------------------------------------
@staff_required
def detail(request, reference):
    r, genre = charger(reference)
    if genre == "hotel":
        sujet = r.hotel.nom
        periode = f"du {r.arrivee:%d/%m/%Y} au {r.depart:%d/%m/%Y}"
    else:
        sujet = f"{r.vehicule.modele} ({r.vehicule.loueur.nom})"
        periode = f"du {r.date_debut:%d/%m/%Y} au {r.date_fin:%d/%m/%Y}"

    try:
        instantane = json.loads(r.detail)
    except ValueError:
        instantane = {"recap": [], "lignes": [], "total": str(r.total_estime),
                      "multiplicateur": ""}

    actions = [a for a, (_, depuis) in ACTIONS.items() if r.statut in depuis]
    return render(request, "gestion/reservation_detail.html", {
        "section": "reservations", "r": r, "genre": genre,
        "genre_label": "Hôtel" if genre == "hotel" else "Véhicule",
        "sujet": sujet, "periode": periode, "instantane": instantane,
        "actions": actions,
        "dispo": dispo_reservation(r, genre),
    })


@staff_required
@require_POST
def changer_statut(request, reference):
    r, genre = charger(reference)
    action = request.POST.get("action", "")
    if action not in ACTIONS:
        messages.error(request, "Action inconnue.")
        return redirect("gestion:reservation_detail", reference=r.reference)

    cible, depuis = ACTIONS[action]
    base = "hotels" if genre == "hotel" else "vehicules"
    refus = None
    modifiees = 0
    with transaction.atomic(using=base):
        if action == "confirmer":
            # Verrou : une seule confirmation à la fois pour cette ressource
            if genre == "hotel":
                TypeChambre.objects.select_for_update().get(pk=r.type_chambre_id)
            else:
                Vehicule.objects.select_for_update().get(pk=r.vehicule_id)
            dispo = dispo_reservation(r, genre)
            if not dispo["disponible"]:
                refus = dispo["message"]
        if refus is None:
            # Mise à jour conditionnelle : ne fait rien si quelqu'un a déjà traité la demande
            modifiees = type(r).objects.filter(pk=r.pk, statut__in=depuis).update(
                statut=cible, modifie_le=timezone.now())

    if refus:
        messages.error(request, "Confirmation impossible : " + refus)
        return redirect("gestion:reservation_detail", reference=r.reference)
    if not modifiees:
        messages.error(
            request, "Cette demande a déjà été traitée par quelqu'un d'autre. "
                     "Rien n'a été modifié.")
        return redirect("gestion:reservation_detail", reference=r.reference)

    messages.success(
        request, f"La demande {r.reference} a été {MESSAGES_ACTION[action]}.")

    if genre == "hotel":
        sujet = r.hotel.nom
        periode = f"du {r.arrivee:%d/%m/%Y} au {r.depart:%d/%m/%Y}"
    else:
        sujet = f"{r.vehicule.modele} ({r.vehicule.loueur.nom})"
        periode = f"du {r.date_debut:%d/%m/%Y} au {r.date_fin:%d/%m/%Y}"

    envoye = envoyer_client(
        r.email_client,
        f"[Honey Group] Votre demande {r.reference} : {MESSAGES_ACTION[action]}",
        corps_statut(r, cible, sujet, periode))
    if envoye:
        messages.success(
            request, f"Le client a été prévenu par e-mail ({masquer_email(r.email_client)}).")
    else:
        messages.error(
            request, "L'e-mail au client n'a pas pu être envoyé : "
                     "écrivez-lui directement depuis sa fiche.")
    return redirect("gestion:reservation_detail", reference=r.reference)


@staff_required
@require_POST
def enregistrer_note(request, reference):
    r, _ = charger(reference)
    note = request.POST.get("note", "").strip()[:2000]
    type(r).objects.filter(pk=r.pk).update(
        note_equipe=note or None, modifie_le=timezone.now())
    messages.success(request, "Note enregistrée.")
    return redirect("gestion:reservation_detail", reference=r.reference)
