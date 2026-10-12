from decimal import Decimal, InvalidOperation

from django.contrib import messages
from django.db import DatabaseError, transaction
from django.db.models import Count
from django.shortcuts import get_object_or_404, redirect, render

from hotels.models import Hotel, Saison, SupplementPension, Tarif, TypeChambre
from vehicules.models import Loueur, SaisonVehicule, TarifVehicule, Vehicule

from .forms_tarifs import (
    SaisonHotelFormSet, SaisonVehiculeFormSet, SupplementFormSet,
    TypeChambreFormSet)
from .views import staff_required

PRIX_MAX = Decimal("9999999999")


# ---------------------------------------------------------------------
# Outils communs
# ---------------------------------------------------------------------
def message_erreur(e):
    code = e.args[0] if e.args and isinstance(e.args[0], int) else None
    if code == 1062:
        return "Enregistrement refusé : ce nom existe déjà."
    if code == 1451:
        return ("Suppression refusée : des cotations utilisent cet élément. "
                "Rien n'a été modifié.")
    return f"Enregistrement refusé par la base de données ({e})."


def lire_prix(brut):
    """Texte -> Decimal, None si vide. Lève ValueError / InvalidOperation."""
    texte = (brut or "").strip().replace(" ", "").replace("\u202f", "")
    texte = texte.replace(",", ".")
    if not texte:
        return None
    prix = Decimal(texte)
    if not prix.is_finite() or prix < 0 or prix > PRIX_MAX:
        raise ValueError("prix hors limites")
    return prix.quantize(Decimal("0.01"))


def texte_prix(prix):
    if prix is None:
        return ""
    return str(int(prix)) if prix == prix.to_integral_value() else str(prix)


def enregistrer_formset(request, formset, champ_parent, parent, base):
    """Ajouts, modifications et suppressions en une seule opération."""
    try:
        with transaction.atomic(using=base):
            instances = formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            for obj in instances:
                setattr(obj, champ_parent, parent)
                obj.save()
        return True
    except DatabaseError as e:
        messages.error(request, message_erreur(e))
        return False


# ---------------------------------------------------------------------
# Index
# ---------------------------------------------------------------------
@staff_required
def index_tarifs(request):
    hotels = Hotel.objects.annotate(
        nb_chambres=Count("types_chambre", distinct=True),
        nb_saisons=Count("saisons", distinct=True),
    ).order_by("-actif", "nom")
    loueurs = Loueur.objects.annotate(
        nb_vehicules=Count("vehicules", distinct=True),
        nb_saisons=Count("saisons", distinct=True),
    ).order_by("-actif", "nom")
    return render(request, "gestion/tarifs_index.html", {
        "section": "tarifs", "hotels": hotels, "loueurs": loueurs})


# ---------------------------------------------------------------------
# Tarifs d'un hôtel
# ---------------------------------------------------------------------
def enregistrer_prix_hotel(request, chambres, saisons):
    modifications, erreurs = [], []
    for tc in chambres:
        for s in saisons:
            brut = request.POST.get(f"prix_{tc.id}_{s.id}", "")
            try:
                modifications.append((tc, s, lire_prix(brut)))
            except (InvalidOperation, ValueError):
                erreurs.append(f"{tc.libelle} / {s.libelle}")
    if erreurs:
        messages.error(
            request,
            "Prix invalide : " + ", ".join(erreurs)
            + ". Utilisez seulement des chiffres positifs. Rien n'a été enregistré.")
        return False
    try:
        with transaction.atomic(using="hotels"):
            for tc, s, prix in modifications:
                if prix is None:
                    Tarif.objects.filter(type_chambre=tc, saison=s).delete()
                else:
                    Tarif.objects.update_or_create(
                        type_chambre=tc, saison=s,
                        defaults={"prix_nuitee": prix})
    except DatabaseError as e:
        messages.error(request, message_erreur(e))
        return False
    messages.success(request, "Les prix ont été enregistrés.")
    return True


@staff_required
def tarifs_hotel(request, pk):
    hotel = get_object_or_404(Hotel, pk=pk)
    qs_chambres = TypeChambre.objects.filter(hotel=hotel).order_by("libelle")
    qs_saisons = Saison.objects.filter(hotel=hotel).order_by("date_debut")
    qs_supp = SupplementPension.objects.filter(
        hotel=hotel).order_by("prix_supplement")

    section = request.POST.get("section") if request.method == "POST" else None

    def formset(classe, prefixe, queryset, cle):
        if section == cle:
            return classe(request.POST, queryset=queryset, prefix=prefixe)
        return classe(queryset=queryset, prefix=prefixe)

    fs_chambres = formset(TypeChambreFormSet, "ch", qs_chambres, "chambres")
    fs_saisons = formset(SaisonHotelFormSet, "sa", qs_saisons, "saisons")
    fs_supp = formset(SupplementFormSet, "su", qs_supp, "supplements")
    jeux = {"chambres": fs_chambres, "saisons": fs_saisons,
            "supplements": fs_supp}

    if section in jeux:
        if jeux[section].is_valid():
            if enregistrer_formset(
                    request, jeux[section], "hotel", hotel, "hotels"):
                messages.success(request, "Modifications enregistrées.")
            return redirect("gestion:tarifs_hotel", pk=hotel.pk)

    colonnes = list(qs_saisons)
    chambres = list(qs_chambres)

    if section == "prix":
        if enregistrer_prix_hotel(request, chambres, colonnes):
            return redirect("gestion:tarifs_hotel", pk=hotel.pk)

    prix_post = request.POST if section == "prix" else None
    existants = {
        (t.type_chambre_id, t.saison_id): t.prix_nuitee
        for t in Tarif.objects.filter(type_chambre__hotel=hotel)}
    lignes = []
    for tc in chambres:
        cellules = []
        for s in colonnes:
            nom = f"prix_{tc.id}_{s.id}"
            if prix_post is not None:
                valeur = prix_post.get(nom, "")
            else:
                valeur = texte_prix(existants.get((tc.id, s.id)))
            cellules.append({"nom": nom, "valeur": valeur})
        lignes.append({"chambre": tc, "cellules": cellules})

    return render(request, "gestion/tarifs_hotel.html", {
        "section": "tarifs", "hotel": hotel,
        "fs_chambres": fs_chambres, "fs_saisons": fs_saisons,
        "fs_supp": fs_supp, "colonnes": colonnes, "lignes": lignes})


# ---------------------------------------------------------------------
# Tarifs d'un loueur
# ---------------------------------------------------------------------
def enregistrer_prix_vehicules(request, vehicules, saisons):
    modifications, erreurs = [], []
    for v in vehicules:
        for s in saisons:
            for ch in (1, 0):
                brut = request.POST.get(f"prix_{v.id}_{s.id}_{ch}", "")
                try:
                    modifications.append((v, s, bool(ch), lire_prix(brut)))
                except (InvalidOperation, ValueError):
                    erreurs.append(f"{v.modele} / {s.libelle}")
    if erreurs:
        messages.error(
            request,
            "Prix invalide : " + ", ".join(sorted(set(erreurs)))
            + ". Utilisez seulement des chiffres positifs. Rien n'a été enregistré.")
        return False
    try:
        with transaction.atomic(using="vehicules"):
            for v, s, ch, prix in modifications:
                filtre = {"vehicule": v, "saison": s, "inclus_chauffeur": ch}
                if prix is None:
                    TarifVehicule.objects.filter(**filtre).delete()
                else:
                    TarifVehicule.objects.update_or_create(
                        **filtre, defaults={"prix_journalier": prix})
    except DatabaseError as e:
        messages.error(request, message_erreur(e))
        return False
    messages.success(request, "Les prix ont été enregistrés.")
    return True


@staff_required
def tarifs_loueur(request, pk):
    loueur = get_object_or_404(Loueur, pk=pk)
    qs_saisons = SaisonVehicule.objects.filter(
        loueur=loueur).order_by("date_debut")

    section = request.POST.get("section") if request.method == "POST" else None

    if section == "saisons":
        fs_saisons = SaisonVehiculeFormSet(
            request.POST, queryset=qs_saisons, prefix="sa")
        if fs_saisons.is_valid():
            if enregistrer_formset(
                    request, fs_saisons, "loueur", loueur, "vehicules"):
                messages.success(request, "Modifications enregistrées.")
            return redirect("gestion:tarifs_loueur", pk=loueur.pk)
    else:
        fs_saisons = SaisonVehiculeFormSet(queryset=qs_saisons, prefix="sa")

    colonnes = list(qs_saisons)
    vehicules = list(Vehicule.objects.filter(loueur=loueur).order_by("modele"))

    if section == "prix":
        if enregistrer_prix_vehicules(request, vehicules, colonnes):
            return redirect("gestion:tarifs_loueur", pk=loueur.pk)

    prix_post = request.POST if section == "prix" else None
    existants = {
        (t.vehicule_id, t.saison_id, int(t.inclus_chauffeur)): t.prix_journalier
        for t in TarifVehicule.objects.filter(vehicule__loueur=loueur)}
    lignes = []
    for v in vehicules:
        cellules = []
        for s in colonnes:
            for ch in (1, 0):
                nom = f"prix_{v.id}_{s.id}_{ch}"
                if prix_post is not None:
                    valeur = prix_post.get(nom, "")
                else:
                    valeur = texte_prix(existants.get((v.id, s.id, ch)))
                cellules.append({"nom": nom, "valeur": valeur})
        lignes.append({"vehicule": v, "cellules": cellules})

    return render(request, "gestion/tarifs_loueur.html", {
        "section": "tarifs", "loueur": loueur,
        "fs_saisons": fs_saisons, "colonnes": colonnes, "lignes": lignes})
