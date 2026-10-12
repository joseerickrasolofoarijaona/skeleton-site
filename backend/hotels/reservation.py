import json

from django.db import IntegrityError, transaction

from honey_site.outils import date_fr, nouvelle_reference

from .models import Reservation


def construire_instantane(hotel, d, resultat):
    """Résumé figé de la demande (affiché tel quel, même si les tarifs changent)."""
    chambre, pension = d["type_chambre"], d["pension"]
    nuits, nb = resultat["nuits"], resultat["nb_chambres"]
    suffixe = f" × {nb} chambres" if nb > 1 else ""
    recap = [
        ["Hôtel", f"{hotel.nom} ({hotel.localisation})"],
        ["Chambre", f"{chambre.libelle} ({chambre.capacite} pers.)"],
        ["Arrivée", date_fr(d["arrivee"])],
        ["Départ", date_fr(d["depart"])],
        ["Durée", f"{nuits} nuit{'s' if nuits > 1 else ''}"],
        ["Nombre de chambres", str(nb)],
        ["Pension", pension.type_pension if pension else "Logement seul"],
    ]
    lignes = [{
        "libelle": f"{l['saison']} ({l['du']:%d/%m} → {l['au']:%d/%m})",
        "quantite": f"{l['nuits']} nuit{'s' if l['nuits'] > 1 else ''}" + suffixe,
        "prix": str(l["prix"]),
        "montant": str(l["montant"]),
    } for l in resultat["lignes"]]
    s = resultat["supplement"]
    if s:
        lignes.append({
            "libelle": s["libelle"],
            "quantite": f"{s['nuits']} nuit{'s' if s['nuits'] > 1 else ''}" + suffixe,
            "prix": str(s["prix"]),
            "montant": str(s["montant"]),
        })
    return {
        "recap": recap,
        "lignes": lignes,
        "total": str(resultat["total"]),
        "multiplicateur": f"Montants calculés pour {nb} chambres." if nb > 1 else "",
    }


def creer_reservation(hotel, d, c, resultat, instantane):
    for _ in range(5):
        r = Reservation(
            reference=nouvelle_reference("HTL"),
            hotel=hotel,
            type_chambre=d["type_chambre"],
            supplement_pension=d["pension"],
            arrivee=d["arrivee"],
            depart=d["depart"],
            nb_chambres=d["nb_chambres"],
            nb_personnes=c["nb_personnes"],
            nom_client=c["nom"],
            email_client=c["email"],
            telephone_client=c["telephone"] or None,
            message=c["message"] or None,
            total_estime=resultat["total"],
            detail=json.dumps(instantane, ensure_ascii=False),
            statut="en_attente",
        )
        try:
            with transaction.atomic(using="hotels"):
                r.save(using="hotels")
            return r
        except IntegrityError as e:
            if e.args and e.args[0] == 1062:      # référence déjà prise : on retente
                continue
            raise
    raise RuntimeError("Impossible de générer une référence unique.")
