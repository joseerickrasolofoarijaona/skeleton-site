from hotels.disponibilite import verifier as verifier_hotel
from vehicules.disponibilite import verifier as verifier_vehicule


def dispo_reservation(r, genre):
    """Disponibilité d'une demande, sans compter la demande elle-même."""
    if genre == "hotel":
        return verifier_hotel(
            r.type_chambre, r.arrivee, r.depart, r.nb_chambres, exclure_pk=r.pk)
    return verifier_vehicule(
        r.vehicule, r.date_debut, r.date_fin, r.nb_vehicules, exclure_pk=r.pk)
