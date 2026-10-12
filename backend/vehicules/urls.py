from django.urls import path

from . import views, views_detail, views_reservation

app_name = "vehicules"

urlpatterns = [
    path("", views.liste_vehicules, name="liste"),
    path("<int:pk>/", views_detail.detail_vehicule, name="detail"),
    path("<int:pk>/reserver/", views_reservation.reserver_vehicule, name="reserver"),
]
