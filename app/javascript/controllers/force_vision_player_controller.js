import { Controller } from "@hotwired/stimulus"
import Plyr from "plyr"

export default class extends Controller {
  static targets = ["video"]

  connect() {
    this.player = new Plyr(this.videoTarget, {
      controls: ["play", "progress", "current-time", "mute", "volume", "fullscreen"]
    })
  }

  disconnect() {
    if (this.player) {
      this.player.destroy()
      this.player = null
    }
  }
}
