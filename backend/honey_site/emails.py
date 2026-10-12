import logging
from decimal import Decimal

from django.conf import settings
from django.core.mail import EmailMessage

logger = logging.getLogger(__name__)


def _envoyer(sujet, corps, destinataire, reply_to=None):
    """Envoie un e-mail. Ne fait jamais échouer l'opération en cours."""
    if not destinataire:
        return False
    try:
        EmailMessage(
            sujet, corps, settings.DEFAULT_FROM_EMAIL, [destinataire],
            reply_to=[reply_to] if reply_to else None,
        ).send(fail_silently=False)
        return True
    except Exception:
        logger.exception("Envoi de l'e-mail impossible (%s).", sujet)
        return False


def notifier_equipe(sujet, corps, reply_to=None):
    destinataire = getattr(settings, "TEAM_EMAIL", "")
    if not destinataire:
        logger.warning("TEAM_EMAIL absent : e-mail non envoyé.")
        return False
    return _envoyer(sujet, corps, destinataire, reply_to)


def envoyer_client(destinataire, sujet, corps):
    """E-mail au client : ses réponses arrivent à l'équipe."""
    return _envoyer(sujet, corps, destinataire,
                    reply_to=getattr(settings, "TEAM_EMAIL", None))


def _montant(valeur):
    return f"{int(Decimal(valeur)):,} Ar".replace(",", " ")


def corps_demande(r, instantane):
    """E-mail à l'équipe pour une nouvelle demande (hôtel ou véhicule)."""
    lignes = [f"Nouvelle demande de réservation : {r.reference}", "", "Détail :"]
    lignes += [f"- {label} : {valeur}" for label, valeur in instantane["recap"]]
    lignes += [
        "",
        f"Total estimé : {_montant(instantane['total'])}",
        "",
        "Client :",
        f"- Nom : {r.nom_client}",
        f"- E-mail : {r.email_client}",
        f"- Téléphone : {r.telephone_client or '—'}",
        f"- Nombre de personnes : {r.nb_personnes}",
        "",
        "Message :",
        r.message or "—",
        "",
        "Répondez directement à cet e-mail pour écrire au client.",
    ]
    return "\n".join(lignes)


def corps_accuse(r, instantane):
    """Accusé de réception envoyé au client."""
    lignes = [
        f"Bonjour {r.nom_client},",
        "",
        "Nous avons bien reçu votre demande et nous vous en remercions.",
        "",
        f"Référence : {r.reference}",
        "",
        "Récapitulatif :",
    ]
    lignes += [f"- {label} : {valeur}" for label, valeur in instantane["recap"]]
    lignes += [
        "",
        f"Total estimé : {_montant(instantane['total'])}",
        "",
        "Notre équipe vérifie la disponibilité et vous répond dans les meilleurs "
        "délais. Aucun paiement n'est demandé à ce stade.",
        "",
        "Pour toute question, répondez simplement à cet e-mail en rappelant "
        "votre référence.",
        "",
        "L'équipe Honey Group",
    ]
    return "\n".join(lignes)


def corps_statut(r, statut, sujet, periode):
    """E-mail envoyé au client quand l'équipe prend une décision."""
    intro = {
        "confirmee": "Bonne nouvelle : votre demande est confirmée.",
        "refusee": "Nous sommes désolés : nous ne pouvons malheureusement pas "
                   "donner suite à votre demande.",
        "annulee": "Votre demande a été annulée.",
    }[statut]
    lignes = [
        f"Bonjour {r.nom_client},",
        "",
        intro,
        "",
        f"Référence : {r.reference}",
        f"Objet : {sujet}",
        f"Période : {periode}",
        f"Total estimé : {_montant(r.total_estime)}",
        "",
    ]
    if statut == "confirmee":
        lignes += ["Notre équipe reste à votre disposition pour finaliser les détails.", ""]
    elif statut == "refusee":
        lignes += ["N'hésitez pas à nous écrire : nous pouvons vous proposer d'autres "
                   "dates ou d'autres partenaires.", ""]
    lignes += [
        "Pour toute question, répondez simplement à cet e-mail en rappelant "
        "votre référence.",
        "",
        "L'équipe Honey Group",
    ]
    return "\n".join(lignes)
