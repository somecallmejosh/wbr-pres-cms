import { Controller } from "@hotwired/stimulus"

// Auto-dismisses flash messages after 5 seconds.
// Provides a close button for manual dismissal with a CSS fade-out transition.
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.#dismiss(), 5000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  close() {
    this.#dismiss()
  }

  #dismiss() {
    this.element.style.transition = "opacity 0.5s ease-out"
    this.element.style.opacity = "0"
    setTimeout(() => this.element.remove(), 500)
  }
}
