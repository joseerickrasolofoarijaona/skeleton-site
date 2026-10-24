from django.urls import path

from . import views, views_detail

app_name = "vehicules"

urlpatterns = [
    path("", views.liste_vehicules, name="liste"),
    path("<int:pk>/", views_detail.detail_vehicule, name="detail"),
]
