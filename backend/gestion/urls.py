from django.contrib.auth.views import LogoutView
from django.urls import path

from . import (
    views, views_reservations as vr, views_tarifs as vt, views_vehicules as vv)

app_name = "gestion"

urlpatterns = [
    path("", vr.tableau_de_bord, name="tableau_de_bord"),
    path("connexion/", views.ConnexionView.as_view(), name="login"),
    path("deconnexion/", LogoutView.as_view(), name="logout"),

    # Hôtels
    path("hotels/", views.hotels, name="hotels"),
    path("hotels/ajouter/", views.hotel_ajouter, name="hotel_ajouter"),
    path("hotels/<int:pk>/modifier/", views.hotel_modifier, name="hotel_modifier"),
    path("hotels/<int:pk>/archiver/", views.hotel_archiver, name="hotel_archiver"),
    path("hotels/<int:pk>/restaurer/", views.hotel_restaurer, name="hotel_restaurer"),
    path("hotels/<int:pk>/tarifs/", vt.tarifs_hotel, name="tarifs_hotel"),

    # Véhicules
    path("vehicules/", vv.liste_vehicules, name="vehicules"),
    path("vehicules/ajouter/", vv.vehicule_ajouter, name="vehicule_ajouter"),
    path("vehicules/<int:pk>/modifier/", vv.vehicule_modifier, name="vehicule_modifier"),
    path("vehicules/<int:pk>/archiver/", vv.vehicule_archiver, name="vehicule_archiver"),
    path("vehicules/<int:pk>/restaurer/", vv.vehicule_restaurer, name="vehicule_restaurer"),

    # Loueurs
    path("loueurs/", vv.liste_loueurs, name="loueurs"),
    path("loueurs/ajouter/", vv.loueur_ajouter, name="loueur_ajouter"),
    path("loueurs/<int:pk>/modifier/", vv.loueur_modifier, name="loueur_modifier"),
    path("loueurs/<int:pk>/archiver/", vv.loueur_archiver, name="loueur_archiver"),
    path("loueurs/<int:pk>/restaurer/", vv.loueur_restaurer, name="loueur_restaurer"),
    path("loueurs/<int:pk>/tarifs/", vt.tarifs_loueur, name="tarifs_loueur"),

    # Tarifs
    path("tarifs/", vt.index_tarifs, name="tarifs"),

    # Réservations
    path("reservations/", vr.liste, name="reservations"),
    path("reservations/<str:reference>/", vr.detail, name="reservation_detail"),
    path("reservations/<str:reference>/statut/", vr.changer_statut, name="reservation_statut"),
    path("reservations/<str:reference>/note/", vr.enregistrer_note, name="reservation_note"),
]
