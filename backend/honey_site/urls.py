from django.contrib import admin
from django.urls import include, path
from django.views.generic import RedirectView

from . import views

urlpatterns = [
    # Côté équipe
    path("gestion/", include("gestion.urls")),
    path("admin/", admin.site.urls),
    # Recherche et cotation
    path("recherche/", views.recherche_globale, name="recherche"),
    path("hotels/", include("hotels.urls")),
    path("vehicules/", include("vehicules.urls")),
    path("", RedirectView.as_view(url="/hotels/", permanent=False)),
]
