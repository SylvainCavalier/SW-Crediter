import { Controller } from "@hotwired/stimulus"
import jsQR from "jsqr"

export default class extends Controller {
  static targets = ["manualInput", "scanButton", "video", "status", "nativeHint"]

  connect() {
    this.scanning = false
    this.useNativeDetector = "BarcodeDetector" in window
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      if (this.hasScanButtonTarget) this.scanButtonTarget.classList.add("d-none")
      if (this.hasNativeHintTarget) this.nativeHintTarget.classList.remove("d-none")
    }
  }

  disconnect() {
    this.stopCamera()
  }

  async startScan() {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      this.statusTarget.textContent = "API camera non disponible sur ce navigateur."
      return
    }

    if (await this.cameraPermissionDenied()) {
      this.showPermissionDeniedHelp()
      return
    }

    this.statusTarget.textContent = "Autorisez l'acces a la camera dans la fenetre du navigateur..."

    try {
      const stream = await this.requestCameraStream()
      this.stream = stream
      this.videoTarget.srcObject = stream
      this.videoTarget.classList.remove("d-none")
      this.scanButtonTarget.classList.add("d-none")
      this.statusTarget.textContent = "Scan en cours..."
      this.scanning = true
      if (this.useNativeDetector) {
        this.detector = new BarcodeDetector({ formats: ["qr_code"] })
      } else {
        this.canvas = document.createElement("canvas")
        this.canvasContext = this.canvas.getContext("2d", { willReadFrequently: true })
      }
      this.scanLoop()
    } catch (error) {
      console.error("Camera error:", error)
      if (error && error.name === "NotAllowedError") {
        this.showPermissionDeniedHelp()
        return
      }
      const reason = error && error.name ? `${error.name}: ${error.message || ""}` : "erreur inconnue"
      this.statusTarget.textContent = `Camera indisponible (${reason}). Utilisez la saisie manuelle.`
    }
  }

  async cameraPermissionDenied() {
    if (!navigator.permissions || !navigator.permissions.query) return false
    try {
      const result = await navigator.permissions.query({ name: "camera" })
      return result.state === "denied"
    } catch (e) {
      return false
    }
  }

  showPermissionDeniedHelp() {
    const standalone = window.matchMedia && window.matchMedia("(display-mode: standalone)").matches
    this.statusTarget.innerHTML = standalone
      ? "Acces a la camera bloque. Pour reactiver depuis l'app installee : <strong>appui long sur l'icone de l'application</strong> sur l'ecran d'accueil &gt; <em>Infos sur l'app</em> &gt; <em>Autorisations</em> &gt; <em>Camera</em> &gt; <em>Autoriser</em>, puis rouvrez l'app."
      : "Acces a la camera bloque. Pour reactiver : touchez l'icone <strong>cadenas</strong> (ou les <strong>trois points</strong>) a cote de l'URL en haut de la page &gt; <em>Autorisations</em> &gt; <em>Camera</em> &gt; <em>Autoriser</em>, puis rechargez la page."
  }

  async requestCameraStream() {
    try {
      return await navigator.mediaDevices.getUserMedia({
        video: { facingMode: { ideal: "environment" } }
      })
    } catch (error) {
      if (error.name === "OverconstrainedError" || error.name === "NotFoundError") {
        return await navigator.mediaDevices.getUserMedia({ video: true })
      }
      throw error
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
      const code = this.useNativeDetector ? await this.detectNative() : this.detectFallback()
      if (code) {
        this.handleScan(code)
        return
      }
    } catch (e) {
      // ignore transient detection errors
    }
    requestAnimationFrame(() => this.scanLoop())
  }

  async detectNative() {
    const barcodes = await this.detector.detect(this.videoTarget)
    return barcodes.length > 0 ? barcodes[0].rawValue : null
  }

  detectFallback() {
    const video = this.videoTarget
    if (video.readyState !== video.HAVE_ENOUGH_DATA) return null
    this.canvas.width = video.videoWidth
    this.canvas.height = video.videoHeight
    this.canvasContext.drawImage(video, 0, 0, this.canvas.width, this.canvas.height)
    const imageData = this.canvasContext.getImageData(0, 0, this.canvas.width, this.canvas.height)
    const result = jsQR(imageData.data, imageData.width, imageData.height, { inversionAttempts: "dontInvert" })
    return result ? result.data : null
  }

  handleScan(rawValue) {
    this.stopCamera()
    this.statusTarget.textContent = "QR Code detecte ! Redirection..."
    if (rawValue.includes("/force_visions/")) {
      window.location.href = rawValue
    } else {
      window.location.href = `/force_visions/${rawValue}`
    }
  }

  manualSubmit() {
    const code = this.manualInputTarget.value.trim()
    if (code) {
      window.location.href = `/force_visions/${code}`
    }
  }
}
