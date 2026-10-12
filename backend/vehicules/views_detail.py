from django.shortcuts import get_object_or_404, render

from .cotation import CotationError, calculer_cotation
from .disponibilite import verifier
from .forms_cotation import CotationVehiculeForm
from .models import SaisonVehicule, TarifVehicule, Vehicule


def detail_vehicule(request, pk):
    vehicule = get_object_or_404(
        Vehicule.objects.select_related("loueur"),
        pk=pk, actif=True, loueur__actif=True)

    saisons = list(
        SaisonVehicule.objects.filter(loueur=vehicule.loueur).order_by("date_debut"))
    prix = {
        (t.saison_id, t.inclus_chauffeur): t.prix_journalier
        for t in TarifVehicule.objects.filter(vehicule=vehicule)}
    grille = [
        {"saison": s, "avec": prix.get((s.id, True)), "sans": prix.get((s.id, False))}
        for s in saisons]

    lance = any(k in request.GET for k in ("debut", "fin", "chauffeur"))
    form = CotationVehiculeForm(request.GET) if lance else CotationVehiculeForm()

    resultat = None
    if lance and form.is_valid():
        d = form.cleaned_data
        try:
            resultat = calculer_cotation(
                vehicule, d["debut"], d["fin"],
                d["chauffeur"] == "1", d["nb_vehicules"])
            resultat.update(debut=d["debut"], fin=d["fin"])
            resultat["dispo"] = verifier(
                vehicule, d["debut"], d["fin"], d["nb_vehicules"])
        except CotationError as e:
            form.add_error(None, str(e))

    return render(request, "vehicules/detail.html", {
        "vehicule": vehicule, "grille": grille, "form": form,
        "resultat": resultat})
