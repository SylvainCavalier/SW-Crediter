import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "fileInput"]

  show(event) {
    if (this.hasFileInputTarget && this.fileInputTarget.files.length > 0) {
      this.overlayTarget.classList.remove("d-none")
    }
  }
}
