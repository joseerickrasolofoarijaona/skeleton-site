from django import template

from hotels.models import Reservation
from vehicules.models import ReservationVehicule

register = template.Library()


@register.simple_tag
def reservations_en_attente():
    """Nombre de demandes à traiter (pastille du menu). Ne casse jamais la page."""
    try:
        return (
            Reservation.objects.filter(statut="en_attente").count()
            + ReservationVehicule.objects.filter(statut="en_attente").count()
        )
    except Exception:
        return 0
