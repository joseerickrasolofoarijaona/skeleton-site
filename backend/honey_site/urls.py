from django.contrib import admin
from django.urls import include, path
from django.views.generic import RedirectView

from . import views, views_reservation

urlpatterns = [
    # Côté admin
    path("gestion/", include("gestion.urls")),
    path("admin/", admin.site.urls),
    # Côté public
    path("recherche/", views.recherche_globale, name="recherche"),
    path("reservation/<str:reference>/", views_reservation.confirmation, name="confirmation"),
    path("hotels/", include("hotels.urls")),
    path("vehicules/", include("vehicules.urls")),
    path("", RedirectView.as_view(url="/hotels/", permanent=False)),
]
