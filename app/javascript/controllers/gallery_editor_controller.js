import { Controller } from "@hotwired/stimulus"

// Drives the two-way photo editor shared by the gallery new + edit pages.
//
// Two modes, chosen by the presence of the `images-url` value:
//
//  - Live (edit page): membership is persisted as it happens. Checking a photo
//    POSTs to add_image (Turbo streams the row in); unchecking / Remove DELETEs.
//    "Save gallery" only touches title/description/published.
//
//  - Staged (new page): the gallery isn't persisted yet, so selections are
//    staged client-side — checking a photo clones a row from the template into
//    the list. The picker checkboxes (image_ids[]) submit with the form, and the
//    controller persists membership on create.
export default class extends Controller {
  static targets = ["list", "empty", "checkbox", "count", "rowTemplate", "autoselect"]
  static values = { imagesUrl: String }

  // In staged mode, rebuild rows for anything already checked (e.g. when the
  // create form re-renders after a validation error).
  connect() {
    if (this.#staged) {
      this.checkboxTargets.filter(checkbox => checkbox.checked).forEach(checkbox => this.#stage(checkbox))
    }
  }

  // Picker checkbox toggled by the user.
  toggle(event) {
    const checkbox = event.target
    if (this.#staged) {
      checkbox.checked ? this.#stage(checkbox) : this.#unstage(checkbox.value)
    } else {
      checkbox.checked ? this.#add(checkbox.value, checkbox) : this.#remove(checkbox.value)
    }
  }

  // Remove button on a photo row.
  remove(event) {
    const row = event.target.closest("[data-image-id]")
    if (!row) return
    this.#staged ? this.#unstage(row.dataset.imageId) : this.#remove(row.dataset.imageId)
  }

  // A freshly uploaded photo streams in a one-shot marker; add it to the
  // gallery (stage on new, persist on edit) and check its picker tile.
  autoselectTargetConnected(marker) {
    const id = marker.value
    marker.remove()
    // Query the DOM (not checkboxTargets) — the new tile may register as a
    // target in the same mutation batch as this marker.
    const checkbox = this.element.querySelector(`input[data-image-id="${id}"]`)
    if (!checkbox || checkbox.checked) return
    checkbox.checked = true
    this.#staged ? this.#stage(checkbox) : this.#add(checkbox.value, checkbox)
  }

  // --- Staged mode (new gallery) -------------------------------------------

  get #staged() {
    return !this.hasImagesUrlValue
  }

  #stage(checkbox) {
    if (this.#rowFor(checkbox.value)) return // already staged

    const imageId = checkbox.value
    const title = checkbox.dataset.imageTitle

    const row = this.rowTemplateTarget.content.firstElementChild.cloneNode(true)
    row.dataset.imageId = imageId
    row.dataset.sortableId = imageId // lets the sortable controller track this row
    row.setAttribute("aria-label", `${title}. Use arrow keys to reorder.`)

    const input = row.querySelector("input[name='image_ids[]']")
    if (input) input.value = imageId // submitted (in drag order) on save
    const img = row.querySelector("img")
    if (img) img.src = checkbox.dataset.imageThumb
    const label = row.querySelector("[data-row-title]")
    if (label) label.textContent = title

    this.listTarget.appendChild(row)
    this.#refresh()
  }

  #unstage(imageId) {
    const checkbox = this.#checkboxFor(imageId)
    if (checkbox) checkbox.checked = false // also clears the peer-checked checkmark

    const row = this.#rowFor(imageId)
    if (row) {
      this.#collapse(row, () => { row.remove(); this.#refresh() })
    } else {
      this.#refresh()
    }
  }

  // --- Live mode (edit gallery) --------------------------------------------

  async #add(imageId, checkbox) {
    try {
      const response = await fetch(this.#url(imageId), {
        method: "POST",
        headers: { Accept: "text/vnd.turbo-stream.html", "X-CSRF-Token": this.#csrfToken }
      })
      if (!response.ok) throw new Error(response.statusText)
      window.Turbo.renderStreamMessage(await response.text())
      this.#refresh()
    } catch {
      // Roll the checkbox back so the UI matches the server.
      if (checkbox) checkbox.checked = false
    }
  }

  async #remove(imageId) {
    try {
      const response = await fetch(this.#url(imageId), {
        method: "DELETE",
        headers: { Accept: "text/vnd.turbo-stream.html", "X-CSRF-Token": this.#csrfToken }
      })
      if (!response.ok) throw new Error(response.statusText)
    } catch {
      return // Leave the UI untouched if the server rejected the delete.
    }

    const checkbox = this.#checkboxFor(imageId)
    if (checkbox) checkbox.checked = false // also clears the peer-checked checkmark

    const row = this.#rowFor(imageId)
    if (row) {
      this.#collapse(row, () => { row.remove(); this.#refresh() })
    } else {
      this.#refresh()
    }
  }

  // --- Shared helpers ------------------------------------------------------

  #rowFor(imageId) {
    return this.listTarget.querySelector(`[data-image-id="${imageId}"]`)
  }

  #checkboxFor(imageId) {
    return this.checkboxTargets.find(checkbox => checkbox.value === String(imageId))
  }

  // Toggles the empty state and updates the live count.
  #refresh() {
    const count = this.listTarget.querySelectorAll("[data-image-id]").length
    this.listTarget.classList.toggle("hidden", count === 0)
    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", count > 0)
    if (this.hasCountTarget) this.countTarget.textContent = count
  }

  #url(imageId) {
    return `${this.imagesUrlValue}/${imageId}`
  }

  get #csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  // Fades + collapses a row's height (siblings slide up), then calls done once.
  #collapse(el, done) {
    let finished = false
    const finish = () => { if (finished) return; finished = true; done() }

    el.style.height = `${el.offsetHeight}px`
    el.style.overflow = "hidden"
    el.getBoundingClientRect() // force reflow so the starting height is applied

    el.style.transition =
      "opacity 0.5s ease, transform 0.5s ease, height 0.5s ease 0.1s, margin 0.5s ease 0.1s, padding 0.5s ease 0.1s"
    el.style.opacity = "0"
    el.style.transform = "translateX(1.5rem)"
    el.style.height = "0px"
    el.style.marginTop = "0px"
    el.style.marginBottom = "0px"
    el.style.paddingTop = "0px"
    el.style.paddingBottom = "0px"

    el.addEventListener("transitionend", finish, { once: true })
    setTimeout(finish, 800) // fallback if transitionend never fires
  }
}
