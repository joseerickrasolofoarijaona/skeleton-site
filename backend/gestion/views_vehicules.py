from django.contrib import messages
from django.db.models import Count
from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse
from django.views.decorators.http import require_POST

from vehicules.forms import LoueurForm, VehiculeForm
from vehicules.models import Loueur, Vehicule

from .views import staff_required


# ---------------------------------------------------------------------
# Véhicules
# ---------------------------------------------------------------------
@staff_required
def liste_vehicules(request):
    liste = list(
        Vehicule.objects.select_related("loueur")
        .order_by("-actif", "loueur__nom", "modele"))
    return render(request, "gestion/vehicules_liste.html", {
        "section": "vehicules",
        "vehicules": liste,
        "nb_actifs": sum(1 for v in liste if v.actif),
        "nb_archives": sum(1 for v in liste if not v.actif),
    })


@staff_required
def vehicule_ajouter(request):
    form = VehiculeForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        v = form.save()
        messages.success(request, f"Le véhicule « {v.modele} » a été ajouté.")
        return redirect("gestion:vehicules")
    return render(request, "gestion/formulaire_simple.html", {
        "section": "vehicules", "form": form, "titre": "Ajouter un véhicule",
        "retour_nom": "Véhicules", "retour_url": reverse("gestion:vehicules")})


@staff_required
def vehicule_modifier(request, pk):
    vehicule = get_object_or_404(Vehicule, pk=pk)
    form = VehiculeForm(request.POST or None, instance=vehicule)
    if request.method == "POST" and form.is_valid():
        v = form.save()
        messages.success(request, f"Le véhicule « {v.modele} » a été modifié.")
        return redirect("gestion:vehicules")
    return render(request, "gestion/formulaire_simple.html", {
        "section": "vehicules", "form": form,
        "titre": f"Modifier : {vehicule.modele}",
        "retour_nom": "Véhicules", "retour_url": reverse("gestion:vehicules")})


@staff_required
@require_POST
def vehicule_archiver(request, pk):
    v = get_object_or_404(Vehicule, pk=pk)
    v.actif = False
    v.save(update_fields=["actif"])
    messages.success(request, f"Le véhicule « {v.modele} » a été archivé.")
    return redirect("gestion:vehicules")


@staff_required
@require_POST
def vehicule_restaurer(request, pk):
    v = get_object_or_404(Vehicule, pk=pk)
    v.actif = True
    v.save(update_fields=["actif"])
    messages.success(request, f"Le véhicule « {v.modele} » est de nouveau en service.")
    return redirect("gestion:vehicules")


# ---------------------------------------------------------------------
# Loueurs
# ---------------------------------------------------------------------
@staff_required
def liste_loueurs(request):
    liste = list(
        Loueur.objects.annotate(nb_vehicules=Count("vehicules"))
        .order_by("-actif", "nom"))
    return render(request, "gestion/loueurs_liste.html", {
        "section": "loueurs",
        "loueurs": liste,
        "nb_actifs": sum(1 for l in liste if l.actif),
        "nb_archives": sum(1 for l in liste if not l.actif),
    })


@staff_required
def loueur_ajouter(request):
    form = LoueurForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        l = form.save()
        messages.success(request, f"Le loueur « {l.nom} » a été ajouté.")
        return redirect("gestion:loueurs")
    return render(request, "gestion/formulaire_simple.html", {
        "section": "loueurs", "form": form, "titre": "Ajouter un loueur",
        "retour_nom": "Loueurs", "retour_url": reverse("gestion:loueurs")})


@staff_required
def loueur_modifier(request, pk):
    loueur = get_object_or_404(Loueur, pk=pk)
    form = LoueurForm(request.POST or None, instance=loueur)
    if request.method == "POST" and form.is_valid():
        l = form.save()
        messages.success(request, f"Le loueur « {l.nom} » a été modifié.")
        return redirect("gestion:loueurs")
    return render(request, "gestion/formulaire_simple.html", {
        "section": "loueurs", "form": form,
        "titre": f"Modifier : {loueur.nom}",
        "retour_nom": "Loueurs", "retour_url": reverse("gestion:loueurs")})


@staff_required
@require_POST
def loueur_archiver(request, pk):
    l = get_object_or_404(Loueur, pk=pk)
    l.actif = False
    l.save(update_fields=["actif"])
    messages.success(
        request,
        f"Le loueur « {l.nom} » a été archivé. Ses véhicules ne sont plus visibles dans la recherche.")
    return redirect("gestion:loueurs")


@staff_required
@require_POST
def loueur_restaurer(request, pk):
    l = get_object_or_404(Loueur, pk=pk)
    l.actif = True
    l.save(update_fields=["actif"])
    messages.success(request, f"Le loueur « {l.nom} » est de nouveau en service.")
    return redirect("gestion:loueurs")
