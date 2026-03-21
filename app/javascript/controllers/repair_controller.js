import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["codeInput", "error", "mainContent", "loadingOverlay",
                     "loadingText", "loadingDetails", "progressBar", "successOverlay"]
  static values = { validateUrl: String, homeUrl: String }

  async submitCode() {
    const code = this.codeInputTarget.value.trim()
    if (!code) {
      this.showError("Veuillez entrer un code.")
      return
    }

    this.errorTarget.textContent = ""
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(this.validateUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ code: code })
      })

      const data = await response.json()

      if (data.success) {
        this.startLoadingSequence()
      } else {
        this.showError(data.error || "Code incorrect.")
        this.shakeInput()
      }
    } catch (error) {
      this.showError("Erreur de connexion. Reessayez.")
    }
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.style.opacity = "1"
  }

  shakeInput() {
    this.codeInputTarget.classList.add("shake")
    setTimeout(() => this.codeInputTarget.classList.remove("shake"), 600)
  }

  startLoadingSequence() {
    this.mainContentTarget.style.display = "none"
    this.loadingOverlayTarget.style.display = "flex"

    const steps = [
      { text: "INITIALISATION DU PROTOCOLE DE REPARATION...", detail: "Connexion au systeme GERVATEX...", progress: 5 },
      { text: "ANALYSE DES COMPOSANTS...", detail: "Verification de l'integrite des pieces...", progress: 15 },
      { text: "CALIBRATION DES OUTILS...", detail: "Alignement des micro-soudures...", progress: 25 },
      { text: "ASSEMBLAGE EN COURS...", detail: "Fusion des circuits primaires...", progress: 40 },
      { text: "SOUDURE DES CONNEXIONS...", detail: "Application du duracier fondu...", progress: 55 },
      { text: "TEST DES SYSTEMES...", detail: "Verification des circuits d'alimentation...", progress: 70 },
      { text: "DIAGNOSTIC FINAL...", detail: "Scan structurel en cours...", progress: 85 },
      { text: "VALIDATION GERVATEX...", detail: "Transmission du rapport au conglomerat...", progress: 95 },
      { text: "REPARATION TERMINEE", detail: "Tous les systemes operationnels.", progress: 100 },
    ]

    let stepIndex = 0
    const stepDuration = 10000 / steps.length // ~10 seconds total

    const interval = setInterval(() => {
      if (stepIndex < steps.length) {
        const step = steps[stepIndex]
        this.loadingTextTarget.textContent = step.text
        this.loadingDetailsTarget.textContent = step.detail
        this.progressBarTarget.style.width = `${step.progress}%`
        stepIndex++
      } else {
        clearInterval(interval)
        setTimeout(() => this.showSuccess(), 500)
      }
    }, stepDuration)
  }

  showSuccess() {
    this.loadingOverlayTarget.style.display = "none"
    this.successOverlayTarget.style.display = "flex"
  }
}
