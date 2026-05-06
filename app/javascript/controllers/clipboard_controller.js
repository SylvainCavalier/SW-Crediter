import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  async copy(event) {
    event.preventDefault()
    const text = this.sourceTarget.value || this.sourceTarget.textContent
    try {
      await navigator.clipboard.writeText(text.trim())
      this.flash("Copie !")
    } catch (e) {
      this.flash("Echec")
    }
  }

  flash(message) {
    if (!this.hasButtonTarget) return
    const original = this.buttonTarget.innerHTML
    this.buttonTarget.innerHTML = message
    setTimeout(() => {
      this.buttonTarget.innerHTML = original
    }, 1200)
  }
}
