from django.urls import path

from . import views, views_detail, views_reservation

app_name = "hotels"

urlpatterns = [
    path("", views.liste_hotels, name="liste"),
    path("<int:pk>/", views_detail.detail_hotel, name="detail"),
    path("<int:pk>/reserver/", views_reservation.reserver_hotel, name="reserver"),
]
