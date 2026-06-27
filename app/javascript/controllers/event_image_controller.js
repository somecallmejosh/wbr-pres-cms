import { Controller } from "@hotwired/stimulus"

// Drives the live "featured photo" picker on the event form.
//
// - Tapping any photo (or "No photo") in the library instantly repaints the
//   big hero preview, so what's selected is never in doubt.
// - On the edit page (updateUrl present) the choice is persisted immediately
//   via PATCH and a "Saved" pip confirms. On the new page there's no event to
//   save to yet, so the radio simply holds the value until the form submits.
export default class extends Controller {
  static targets = ["image", "placeholder", "caption", "status", "autoselect"]
  static values = { updateUrl: String }

  // Fired by change-> on each library radio.
  select(event) {
    this.#choose(event.target)
  }

  // A freshly uploaded photo streams in a hidden marker carrying its id; we
  // pick it as the featured image (repaint + save), then drop the marker.
  autoselectTargetConnected(marker) {
    const id = marker.value
    marker.remove()
    this.#choose(this.element.querySelector(`input[name="event[image_id]"][value="${id}"]`))
  }

  // Select a radio: check it (unchecking its group), repaint, persist on edit.
  #choose(radio) {
    if (!radio) return
    radio.checked = true
    const tile = radio.closest("[data-event-image-url]")
    this.#paint(tile?.dataset.eventImageUrl, tile?.dataset.eventImageTitle)
    if (this.hasUpdateUrlValue) this.#save(radio.value)
  }

  // Repaint the hero preview to match the current choice (optimistic).
  #paint(url, title) {
    const hasImage = Boolean(url)
    if (hasImage) this.imageTarget.src = url
    this.imageTarget.classList.toggle("hidden", !hasImage)
    this.placeholderTarget.classList.toggle("hidden", hasImage)
    if (this.hasCaptionTarget) {
      this.captionTarget.textContent = hasImage
        ? (title || "Featured on this event")
        : "No photo selected"
    }
  }

  async #save(imageId) {
    try {
      const response = await fetch(this.updateUrlValue, {
        method: "PATCH",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": this.#csrfToken
        },
        body: new URLSearchParams({ "event[image_id]": imageId })
      })
      if (!response.ok) throw new Error(response.statusText)
      this.#flashSaved()
    } catch {
      // Quiet failure: the next "Save event" submit is the safety net.
    }
  }

  // Briefly reveal the "Saved" pip, then fade it back out.
  #flashSaved() {
    if (!this.hasStatusTarget) return
    const pip = this.statusTarget
    pip.classList.remove("opacity-0")
    pip.classList.add("opacity-100")
    clearTimeout(this.statusTimer)
    this.statusTimer = setTimeout(() => {
      pip.classList.remove("opacity-100")
      pip.classList.add("opacity-0")
    }, 1600)
  }

  get #csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
