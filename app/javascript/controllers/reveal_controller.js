import { Controller } from "@hotwired/stimulus"

// Gentle, GPU-only scroll-reveal. Elements fade and rise into place as they
// enter the viewport. Degrades gracefully: if JS is disabled the markup is
// never hidden, and reduced-motion users see everything immediately.
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 0 },
    threshold: { type: Number, default: 0.12 },
  }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.element.classList.add("reveal-init", "reveal-active")
    if (this.delayValue > 0) {
      this.element.style.transitionDelay = `${this.delayValue}ms`
    }

    // An element taller than the viewport can never reach a high intersection
    // ratio, so a fixed threshold would leave it hidden forever. When that's the
    // case, fall back to 0 so it reveals as soon as any part scrolls into view.
    const viewportHeight = window.innerHeight || document.documentElement.clientHeight
    const threshold =
      this.element.offsetHeight >= viewportHeight ? 0 : this.thresholdValue

    this.observer = new IntersectionObserver(
      (entries, observer) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            this.element.classList.add("reveal-in")
            observer.unobserve(entry.target)
          }
        })
      },
      { threshold, rootMargin: "0px 0px -8% 0px" }
    )

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
