from django.contrib import messages
from django.contrib.auth.decorators import user_passes_test
from django.contrib.auth.views import LoginView
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.http import require_POST

from hotels.forms import HotelForm
from hotels.models import Hotel, HotelEquipement
from vehicules.models import Loueur, Vehicule

from .forms import FormulaireConnexion, ParametresForm
from .models import Parametres

# Accès réservé aux comptes de l'équipe
staff_required = user_passes_test(
    lambda u: u.is_active and u.is_staff, login_url="gestion:login"
)


class ConnexionView(LoginView):
    template_name = "gestion/connexion.html"
    authentication_form = FormulaireConnexion


@staff_required
def tableau_de_bord(request):
    return render(request, "gestion/tableau_de_bord.html", {
        "section": "accueil",
        "hotels_actifs": Hotel.objects.filter(actif=True).count(),
        "hotels_archives": Hotel.objects.filter(actif=False).count(),
        "vehicules_actifs": Vehicule.objects.filter(actif=True).count(),
        "vehicules_archives": Vehicule.objects.filter(actif=False).count(),
        "loueurs_actifs": Loueur.objects.filter(actif=True).count(),
    })


# ---------------------------------------------------------------------
# Paramètres (taux de change)
# ---------------------------------------------------------------------
@staff_required
def parametres(request):
    p, _ = Parametres.objects.get_or_create(pk=1)
    form = ParametresForm(request.POST or None, instance=p)
    if request.method == "POST" and form.is_valid():
        obj = form.save(commit=False)
        obj.defini = True
        obj.save()
        messages.success(request, "Le taux de change a été enregistré.")
        return redirect("gestion:parametres")
    return render(request, "gestion/parametres.html", {
        "section": "parametres", "form": form})


# ---------------------------------------------------------------------
# Hôtels
# ---------------------------------------------------------------------
@staff_required
def hotels(request):
    liste = list(Hotel.objects.order_by("-actif", "nom"))
    return render(request, "gestion/hotels_liste.html", {
        "section": "hotels",
        "hotels": liste,
        "nb_actifs": sum(1 for h in liste if h.actif),
        "nb_archives": sum(1 for h in liste if not h.actif),
    })


@staff_required
def hotel_ajouter(request):
    form = HotelForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        hotel = form.enregistrer()
        messages.success(request, f"L'hôtel « {hotel.nom} » a été ajouté.")
        return redirect("gestion:hotels")
    return render(request, "gestion/hotel_formulaire.html", {
        "section": "hotels", "form": form, "titre": "Ajouter un hôtel"})


@staff_required
def hotel_modifier(request, pk):
    hotel = get_object_or_404(Hotel, pk=pk)
    initial = {
        "equipements": list(
            HotelEquipement.objects.filter(hotel=hotel)
            .values_list("equipement_id", flat=True)),
        "categorie": hotel.categorie or "",
    }
    form = HotelForm(request.POST or None, instance=hotel, initial=initial)
    if request.method == "POST" and form.is_valid():
        hotel = form.enregistrer()
        messages.success(request, f"L'hôtel « {hotel.nom} » a été modifié.")
        return redirect("gestion:hotels")
    return render(request, "gestion/hotel_formulaire.html", {
        "section": "hotels", "form": form, "titre": f"Modifier : {hotel.nom}"})


@staff_required
@require_POST
def hotel_archiver(request, pk):
    hotel = get_object_or_404(Hotel, pk=pk)
    hotel.actif = False
    hotel.save(update_fields=["actif"])
    messages.success(request, f"L'hôtel « {hotel.nom} » a été archivé.")
    return redirect("gestion:hotels")


@staff_required
@require_POST
def hotel_restaurer(request, pk):
    hotel = get_object_or_404(Hotel, pk=pk)
    hotel.actif = True
    hotel.save(update_fields=["actif"])
    messages.success(request, f"L'hôtel « {hotel.nom} » est de nouveau en service.")
    return redirect("gestion:hotels")
