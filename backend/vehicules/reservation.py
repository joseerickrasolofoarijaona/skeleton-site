import json

from django.db import IntegrityError, transaction

from honey_site.outils import date_fr, nouvelle_reference

from .models import ReservationVehicule


def construire_instantane(vehicule, d, resultat):
    jours, nb = resultat["jours"], resultat["nb_vehicules"]
    suffixe = f" × {nb} véhicules" if nb > 1 else ""
    avec = resultat["avec_chauffeur"]
    recap = [
        ["Véhicule", f"{vehicule.modele} ({vehicule.categorie})"],
        ["Loueur", vehicule.loueur.nom],
        ["Début", date_fr(d["debut"])],
        ["Fin", date_fr(d["fin"])],
        ["Durée", f"{jours} jour{'s' if jours > 1 else ''}"],
        ["Nombre de véhicules", str(nb)],
        ["Chauffeur", "Avec chauffeur" if avec else "Sans chauffeur"],
    ]
    lignes = [{
        "libelle": f"{l['saison']} ({l['du']:%d/%m} → {l['au']:%d/%m})",
        "quantite": f"{l['jours']} jour{'s' if l['jours'] > 1 else ''}" + suffixe,
        "prix": str(l["prix"]),
        "montant": str(l["montant"]),
    } for l in resultat["lignes"]]
    return {
        "recap": recap,
        "lignes": lignes,
        "total": str(resultat["total"]),
        "multiplicateur": f"Montants calculés pour {nb} véhicules." if nb > 1 else "",
    }


def creer_reservation(vehicule, d, c, resultat, instantane):
    for _ in range(5):
        r = ReservationVehicule(
            reference=nouvelle_reference("VEH"),
            vehicule=vehicule,
            date_debut=d["debut"],
            date_fin=d["fin"],
            avec_chauffeur=resultat["avec_chauffeur"],
            nb_vehicules=d["nb_vehicules"],
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
            with transaction.atomic(using="vehicules"):
                r.save(using="vehicules")
            return r
        except IntegrityError as e:
            if e.args and e.args[0] == 1062:
                continue
            raise
    raise RuntimeError("Impossible de générer une référence unique.")
