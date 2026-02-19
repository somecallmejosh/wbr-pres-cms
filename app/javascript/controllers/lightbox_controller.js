import { Controller } from "@hotwired/stimulus"

// Opens a full-screen lightbox overlay when a gallery image is clicked.
//
// Keyboard support:
//   Escape        — close the lightbox
//   ArrowLeft     — previous image
//   ArrowRight    — next image
//   Tab / Shift+Tab — cycles focus among the three buttons (close, prev, next)
//
// Accessibility:
//   - Overlay has role="dialog", aria-modal="true", aria-label
//   - Focus is trapped inside the dialog while open
//   - Focus returns to the triggering element on close
//   - Screen readers receive a descriptive aria-label on the dialog
export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.overlay = null
    this.triggerElement = null
    this.currentIndex = 0
  }

  disconnect() {
    this.#close()
  }

  open(event) {
    const item = event.currentTarget
    this.triggerElement = item
    this.currentIndex = this.itemTargets.indexOf(item)
    this.#render()
  }

  #render() {
    this.overlay?.remove()
    document.removeEventListener("keydown", this.#onKeydown)

    const items = this.itemTargets
    const item = items[this.currentIndex]
    const src = item.dataset.lightboxSrc
    const alt = item.dataset.lightboxAlt || ""
    const isFirst = this.currentIndex === 0
    const isLast = this.currentIndex === items.length - 1
    const position = `${this.currentIndex + 1} of ${items.length}`

    this.overlay = document.createElement("div")
    this.overlay.setAttribute("role", "dialog")
    this.overlay.setAttribute("aria-modal", "true")
    this.overlay.setAttribute("aria-label", `Image viewer — ${alt || position}`)
    this.overlay.className = "fixed inset-0 z-50 flex items-center justify-center bg-black/90 p-4"

    // Close button
    const closeBtn = this.#createButton("close", "&times;", "Close image viewer (Escape)", "absolute top-4 right-4 text-white text-4xl w-12 h-12 flex items-center justify-center rounded hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-white")

    // Previous button
    const prevBtn = this.#createButton("prev", "&#8249;", "Previous image (Arrow Left)", `absolute left-4 text-white text-5xl w-12 h-full flex items-center justify-center rounded hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-white${isFirst ? " opacity-30 cursor-not-allowed" : ""}`)
    if (isFirst) prevBtn.setAttribute("disabled", "")
    prevBtn.setAttribute("aria-disabled", String(isFirst))

    // Next button
    const nextBtn = this.#createButton("next", "&#8250;", "Next image (Arrow Right)", `absolute right-4 text-white text-5xl w-12 h-full flex items-center justify-center rounded hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-white${isLast ? " opacity-30 cursor-not-allowed" : ""}`)
    if (isLast) nextBtn.setAttribute("disabled", "")
    nextBtn.setAttribute("aria-disabled", String(isLast))

    // Image
    const img = document.createElement("img")
    img.src = src
    img.alt = alt
    img.className = "max-h-[90vh] max-w-[calc(100vw-8rem)] object-contain"

    // Position indicator (screen-reader visible)
    const positionEl = document.createElement("p")
    positionEl.className = "sr-only"
    positionEl.textContent = `Image ${position}`

    this.overlay.append(closeBtn, prevBtn, img, nextBtn, positionEl)

    // Close on backdrop click (not on child elements)
    this.overlay.addEventListener("click", (e) => {
      if (e.target === this.overlay) this.#close()
    })

    closeBtn.addEventListener("click", () => this.#close())
    prevBtn.addEventListener("click", () => this.#navigate(-1))
    nextBtn.addEventListener("click", () => this.#navigate(1))

    // Keyboard handler
    document.addEventListener("keydown", this.#onKeydown)

    // Focus trap
    this.overlay.addEventListener("keydown", this.#onFocusTrap)

    document.body.appendChild(this.overlay)
    closeBtn.focus()
  }

  #close() {
    if (!this.overlay) return
    document.removeEventListener("keydown", this.#onKeydown)
    this.overlay.remove()
    this.overlay = null
    this.triggerElement?.focus()
    this.triggerElement = null
  }

  #navigate(direction) {
    const newIndex = this.currentIndex + direction
    if (newIndex >= 0 && newIndex < this.itemTargets.length) {
      this.currentIndex = newIndex
      this.#render()
    }
  }

  // Bound as property so addEventListener/removeEventListener work correctly
  #onKeydown = (event) => {
    switch (event.key) {
      case "Escape":
        event.preventDefault()
        this.#close()
        break
      case "ArrowLeft":
        event.preventDefault()
        this.#navigate(-1)
        break
      case "ArrowRight":
        event.preventDefault()
        this.#navigate(1)
        break
    }
  }

  #onFocusTrap = (event) => {
    if (event.key !== "Tab" || !this.overlay) return

    const focusable = [...this.overlay.querySelectorAll("button:not([disabled])")]
    if (focusable.length === 0) return

    const first = focusable[0]
    const last = focusable[focusable.length - 1]

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }

  #createButton(name, html, label, className) {
    const btn = document.createElement("button")
    btn.type = "button"
    btn.innerHTML = html
    btn.setAttribute("aria-label", label)
    btn.className = className
    return btn
  }
}
