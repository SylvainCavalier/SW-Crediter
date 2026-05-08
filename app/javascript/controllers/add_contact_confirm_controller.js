import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "input"]

  connect() {
    this.boundPopulate = this.populate.bind(this)
    this.element.addEventListener("show.bs.modal", this.boundPopulate)
  }

  disconnect() {
    this.element.removeEventListener("show.bs.modal", this.boundPopulate)
  }

  populate(event) {
    const trigger = event.relatedTarget
    if (!trigger) return
    if (this.hasInputTarget) this.inputTarget.value = trigger.dataset.contactName || ""
    if (this.hasLabelTarget) this.labelTarget.textContent = trigger.dataset.contactLabel || ""
  }
}
