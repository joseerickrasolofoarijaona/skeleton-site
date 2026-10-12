"""Calcul d'une cotation véhicule, jour par jour, saison par saison."""
from datetime import timedelta
from decimal import Decimal

from .models import SaisonVehicule, TarifVehicule

JOURS_MAX = 90


class CotationError(Exception):
    """Cotation impossible : dates incohérentes, saison ou tarif manquant."""


def calculer_cotation(vehicule, debut, fin, avec_chauffeur, nb_vehicules):
    if fin < debut:
        raise CotationError("La fin doit être le même jour ou après le début.")
    jours = (fin - debut).days + 1          # début et fin inclus
    if jours > JOURS_MAX:
        raise CotationError(f"Une cotation est limitée à {JOURS_MAX} jours.")

    saisons = list(
        SaisonVehicule.objects.filter(
            loueur_id=vehicule.loueur_id,
            date_debut__lte=fin,
            date_fin__gte=debut,
        ).order_by("-date_debut", "id")
    )
    prix_par_saison = {
        t.saison_id: t.prix_journalier
        for t in TarifVehicule.objects.filter(
            vehicule=vehicule, inclus_chauffeur=avec_chauffeur)
    }
    option = "avec" if avec_chauffeur else "sans"

    segments = {}
    for i in range(jours):
        jour = debut + timedelta(days=i)
        saison = next(
            (s for s in saisons if s.date_debut <= jour <= s.date_fin), None)
        if saison is None:
            raise CotationError(
                f"Aucune saison n'est définie pour le {jour:%d/%m/%Y}. "
                "Contactez-nous pour un tarif sur mesure.")
        prix = prix_par_saison.get(saison.id)
        if prix is None:
            raise CotationError(
                f"Aucun tarif {option} chauffeur n'est défini pour "
                f"{vehicule.modele} en {saison.libelle}.")
        seg = segments.setdefault(saison.id, {
            "saison": saison.libelle, "du": jour, "au": jour,
            "jours": 0, "prix": prix})
        seg["jours"] += 1
        seg["au"] = jour

    total = Decimal("0")
    lignes = []
    for seg in segments.values():
        seg["montant"] = seg["prix"] * seg["jours"] * nb_vehicules
        total += seg["montant"]
        lignes.append(seg)

    return {
        "jours": jours,
        "nb_vehicules": nb_vehicules,
        "avec_chauffeur": avec_chauffeur,
        "lignes": lignes,
        "total": total,
    }
