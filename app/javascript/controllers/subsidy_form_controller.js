import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "resetMessage", "resetReason", "submitBtn", "republiqueSelect"]

  resetForm(reason) {
    this.resetReasonTarget.textContent = reason

    // Show the overlay
    const overlay = this.resetMessageTarget
    overlay.classList.remove("d-none")
    overlay.style.display = "flex"

    // Reset the form
    this.formTarget.reset()

    // Hide after clicking anywhere on the overlay or after 6 seconds
    const hideOverlay = () => {
      overlay.style.display = "none"
      overlay.classList.add("d-none")
      overlay.removeEventListener("click", hideOverlay)
    }

    overlay.addEventListener("click", hideOverlay)
    setTimeout(hideOverlay, 6000)
  }

  trapEspaceSauvage(event) {
    if (event.target.value === "oui") {
      this.resetForm(
        "Les citoyens ayant séjourné dans l'Espace Sauvage sont soumis à la procédure renforcée GR-7742-D. " +
        "Veuillez remplir à nouveau le formulaire standard avant de pouvoir accéder au formulaire renforcé."
      )
    }
  }

  trapEnrichissement(event) {
    if (event.target.checked) {
      this.resetForm(
        "L'enrichissement personnel ne constitue pas un motif recevable de subvention républicaine " +
        "(Directive 12-B du Comité d'Éthique du Sénat). Votre dossier a été signalé. Veuillez recommencer."
      )
    }
  }

  trapEnquete(event) {
    if (event.target.value === "oui") {
      this.resetForm(
        "Les citoyens faisant l'objet d'une enquête du Bureau de Conformité Fiscale ne sont pas éligibles " +
        "aux subventions républicaines. Votre numéro d'identification a été transmis aux autorités compétentes. " +
        "Veuillez recommencer la procédure après régularisation de votre situation."
      )
    }
  }

  trapSeparatiste(event) {
    if (event.target.value === "oui") {
      this.resetForm(
        "ALERTE DE SÉCURITÉ — Affiliation séparatiste détectée. Conformément au Décret d'Urgence 66... " +
        "euh, pardon, au Protocole de Sécurité Standard, votre demande est annulée. " +
        "Veuillez vous présenter au Bureau de Sécurité Républicain le plus proche. En attendant, vous pouvez recommencer."
      )
    }
  }

  trapKyber(event) {
    if (event.target.value === "oui") {
      this.resetForm(
        "La possession non déclarée de cristaux Kyber est une infraction de classe Besh au Code Minier Galactique. " +
        "Votre aveu a été enregistré. Vous êtes prié(e) de recommencer le formulaire en toute honnêteté cette fois."
      )
    }
  }

  trapRefus(event) {
    if (event.target.checked) {
      this.resetForm(
        "Vous avez refusé le Serment Galactique. Sans ce serment, aucune demande de subvention ne peut être traitée. " +
        "Votre refus a été consigné dans votre dossier permanent. Veuillez recommencer si vous changez d'avis."
      )
    }
  }

  trapPriorite(event) {
    if (event.target.value === "zerek") {
      this.resetForm(
        "Une demande de subvention avec un code de priorité Zerek (Aucune) est automatiquement classée sans suite. " +
        "Si votre mission n'a aucune priorité, pourquoi demander des crédits ? Veuillez recommencer avec un motif valable."
      )
    }
  }

  trapRepublique(event) {
    const value = event.target.value
    if (value === "corrompue") {
      this.resetForm(
        "Votre réponse a été jugée séditieuse par le Module de Détection Anti-Subversion. " +
        "Une note a été ajoutée à votre dossier citoyen. Veuillez recommencer et répondre avec plus de patriotisme."
      )
    } else if (value === "acceptable") {
      this.resetForm(
        "La réponse « acceptable » ne reflète pas le niveau d'enthousiasme minimum requis par la Circulaire 88-A " +
        "du Bureau de la Propagande Républicaine. Veuillez reconsidérer votre réponse."
      )
    } else if (value === "parfaite") {
      this.resetForm(
        "Réponse suspecte. Un système parfait n'a pas besoin de subventions. Incohérence détectée dans votre dossier. " +
        "Veuillez recommencer la procédure."
      )
    }
    // Seule "vive" est acceptée
  }

  trapChancelier(event) {
    const value = parseInt(event.target.value)
    if (value < 3) {
      this.resetForm(
        "Votre évaluation du Chancelier Suprême est en dessous du seuil d'appréciation minimum fixé par le " +
        "Décret Exécutif 1138. Cette réponse a été transmise au Service de Surveillance Citoyenne. " +
        "Veuillez recommencer le formulaire avec une attitude plus constructive."
      )
    }
    // Seuls "Très satisfaisant" (3) et "Extatique" (4) passent
  }
}
