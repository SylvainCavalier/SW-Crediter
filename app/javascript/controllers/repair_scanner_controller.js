import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["manualInput", "scanButton", "video", "status", "nativeHint"]

  connect() {
    this.scanning = false
    if (!("BarcodeDetector" in window)) {
      if (this.hasScanButtonTarget) this.scanButtonTarget.classList.add("d-none")
      if (this.hasNativeHintTarget) this.nativeHintTarget.classList.remove("d-none")
    }
  }

  disconnect() {
    this.stopCamera()
  }

  async startScan() {
    if (!("BarcodeDetector" in window)) return

    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment" }
      })
      this.stream = stream
      this.videoTarget.srcObject = stream
      this.videoTarget.classList.remove("d-none")
      this.scanButtonTarget.classList.add("d-none")
      this.statusTarget.textContent = "Scan en cours..."
      this.scanning = true
      this.detector = new BarcodeDetector({ formats: ["qr_code"] })
      this.scanLoop()
    } catch (error) {
      console.error("Camera error:", error)
      this.statusTarget.textContent = "Camera indisponible. Utilisez la saisie manuelle."
    }
  }

  stopCamera() {
    this.scanning = false
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }
  }

  async scanLoop() {
    if (!this.scanning) return
    try {
      const barcodes = await this.detector.detect(this.videoTarget)
      if (barcodes.length > 0) {
        this.handleScan(barcodes[0].rawValue)
        return
      }
    } catch (e) {
      // ignore transient detection errors
    }
    requestAnimationFrame(() => this.scanLoop())
  }

  handleScan(rawValue) {
    this.stopCamera()
    this.statusTarget.textContent = "QR Code detecte ! Redirection..."
    if (rawValue.includes("/repairs/")) {
      window.location.href = rawValue
    } else {
      window.location.href = `/repairs/${rawValue}`
    }
  }

  manualSubmit() {
    const code = this.manualInputTarget.value.trim()
    if (code) {
      window.location.href = `/repairs/${code}`
    }
  }
}
