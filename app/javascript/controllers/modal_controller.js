import { Controller } from "@hotwired/stimulus"

// Drives a native <dialog> rendered inside the "modal" Turbo Frame.
// Opens on connect (the card fades in via CSS @starting-style), and closes on
// backdrop click, Escape, or the X / Cancel buttons. Closing clears the frame
// so the next open fetches a fresh form. On a successful save the server
// replaces the frame with empty content, which disconnects this controller.
export default class extends Controller {
  connect() {
    this.dialog = this.element

    if (typeof this.dialog.showModal === "function" && !this.dialog.open) {
      this.dialog.showModal()
    }
    // The card fades in via CSS @starting-style (Tailwind `starting:`) — no JS
    // timing, and the element is at its final geometry immediately.

    // Backdrop click: a click whose target is the dialog itself (the area
    // around the card) dismisses the modal.
    this.onBackdrop = (event) => {
      if (event.target === this.dialog) this.close()
    }
    this.dialog.addEventListener("click", this.onBackdrop)

    // Route the native Escape ("cancel") through our cleanup path.
    this.onCancel = (event) => {
      event.preventDefault()
      this.close()
    }
    this.dialog.addEventListener("cancel", this.onCancel)
  }

  disconnect() {
    this.dialog.removeEventListener("click", this.onBackdrop)
    this.dialog.removeEventListener("cancel", this.onCancel)
  }

  close(event) {
    if (event) event.preventDefault()
    if (this.dialog.open) this.dialog.close()

    // Empty the Turbo Frame so re-opening loads a fresh form.
    const frame = this.dialog.closest("turbo-frame")
    if (frame) frame.innerHTML = ""
  }
}
