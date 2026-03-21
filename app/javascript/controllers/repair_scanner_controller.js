import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "viewport", "status", "scanLine", "manualInput"]

  connect() {
    this.scanning = false
    this.startCamera()
  }

  disconnect() {
    this.stopCamera()
  }

  async startCamera() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment" }
      })
      this.videoTarget.srcObject = stream
      this.stream = stream
      this.statusTarget.innerHTML = '<i class="fa-solid fa-camera"></i> Camera active - Scannez un QR Code'
      this.scanning = true
      this.scanLoop()
    } catch (error) {
      console.error("Camera error:", error)
      this.statusTarget.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> Camera indisponible. Utilisez la saisie manuelle.'
      this.viewportTarget.style.display = "none"
    }
  }

  stopCamera() {
    this.scanning = false
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
    }
  }

  async scanLoop() {
    if (!this.scanning) return

    // Check if BarcodeDetector is available
    if ("BarcodeDetector" in window) {
      try {
        if (!this.detector) {
          this.detector = new BarcodeDetector({ formats: ["qr_code"] })
        }
        const barcodes = await this.detector.detect(this.videoTarget)
        if (barcodes.length > 0) {
          this.handleScan(barcodes[0].rawValue)
          return
        }
      } catch (e) {
        // Continue scanning
      }
    } else {
      // Fallback: try using canvas-based detection won't work without library
      // Show manual entry message
      this.statusTarget.innerHTML = '<i class="fa-solid fa-keyboard"></i> Scanner non supporte par ce navigateur. Utilisez la saisie manuelle.'
      this.scanning = false
      return
    }

    requestAnimationFrame(() => this.scanLoop())
  }

  handleScan(rawValue) {
    this.scanning = false
    this.stopCamera()
    this.statusTarget.innerHTML = '<i class="fa-solid fa-check"></i> QR Code detecte ! Redirection...'

    // The QR code contains either a full URL or just the token
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
