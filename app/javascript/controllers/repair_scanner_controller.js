import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["manualInput"]

  manualSubmit() {
    const code = this.manualInputTarget.value.trim()
    if (code) {
      window.location.href = `/repairs/${code}`
    }
  }
}
