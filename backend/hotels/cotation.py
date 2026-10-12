"""Calcul d'une cotation hôtel, nuit par nuit, saison par saison."""
from datetime import timedelta
from decimal import Decimal

from .models import Saison, Tarif

NUITS_MAX = 90


class CotationError(Exception):
    """Cotation impossible : dates incohérentes, saison ou tarif manquant."""


def calculer_cotation(type_chambre, arrivee, depart, nb_chambres, supplement=None):
    if depart <= arrivee:
        raise CotationError("La date de départ doit être après la date d'arrivée.")
    nuits = (depart - arrivee).days
    if nuits > NUITS_MAX:
        raise CotationError(f"Une cotation est limitée à {NUITS_MAX} nuits.")

    # Saisons de l'hôtel qui touchent le séjour (la plus récente l'emporte)
    saisons = list(
        Saison.objects.filter(
            hotel_id=type_chambre.hotel_id,
            date_debut__lt=depart,
            date_fin__gte=arrivee,
        ).order_by("-date_debut", "id")
    )
    prix_par_saison = {
        t.saison_id: t.prix_nuitee
        for t in Tarif.objects.filter(type_chambre=type_chambre)
    }

    segments = {}
    for i in range(nuits):
        jour = arrivee + timedelta(days=i)
        saison = next(
            (s for s in saisons if s.date_debut <= jour <= s.date_fin), None)
        if saison is None:
            raise CotationError(
                f"Aucune saison n'est définie pour la nuit du {jour:%d/%m/%Y}. "
                "Contactez-nous pour un tarif sur mesure.")
        prix = prix_par_saison.get(saison.id)
        if prix is None:
            raise CotationError(
                f"Aucun tarif n'est défini pour « {type_chambre.libelle} » "
                f"en {saison.libelle}.")
        seg = segments.setdefault(saison.id, {
            "saison": saison.libelle, "du": jour, "au": jour,
            "nuits": 0, "prix": prix})
        seg["nuits"] += 1
        seg["au"] = jour

    total = Decimal("0")
    lignes = []
    for seg in segments.values():
        seg["montant"] = seg["prix"] * seg["nuits"] * nb_chambres
        total += seg["montant"]
        lignes.append(seg)

    ligne_supplement = None
    if supplement is not None:
        montant = supplement.prix_supplement * nuits * nb_chambres
        total += montant
        ligne_supplement = {
            "libelle": supplement.type_pension,
            "prix": supplement.prix_supplement,
            "nuits": nuits,
            "montant": montant,
        }

    return {
        "nuits": nuits,
        "nb_chambres": nb_chambres,
        "lignes": lignes,
        "supplement": ligne_supplement,
        "total": total,
    }
