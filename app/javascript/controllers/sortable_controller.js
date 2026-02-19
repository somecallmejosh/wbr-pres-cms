import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Enables drag-and-drop (and keyboard) reordering of gallery images.
// Persists new order via PATCH to data-sortable-url-value.
//
// Keyboard usage (when an item is focused):
//   ArrowUp / ArrowDown — move the item up or down one position
//
// Accessibility:
//   - Items have tabindex="0" and role="listitem" set in the partial
//   - A live region announces position changes to screen readers
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-sortable-handle]",
      ghostClass: "opacity-50",
      onEnd: () => this.#save()
    })

    this.element.querySelectorAll("[data-sortable-id]").forEach(item => {
      item.addEventListener("keydown", this.#onKeydown)
    })
  }

  disconnect() {
    this.sortable?.destroy()
    this.element.querySelectorAll("[data-sortable-id]").forEach(item => {
      item.removeEventListener("keydown", this.#onKeydown)
    })
  }

  // Arrow-key reordering — bound as a property so removeEventListener works
  #onKeydown = (event) => {
    if (event.key !== "ArrowUp" && event.key !== "ArrowDown") return
    event.preventDefault()

    const item = event.currentTarget
    const items = [...this.element.querySelectorAll("[data-sortable-id]")]
    const index = items.indexOf(item)

    if (event.key === "ArrowUp" && index > 0) {
      this.element.insertBefore(item, items[index - 1])
      item.focus()
      this.#save()
      this.#announce(`Moved to position ${index}`)
    } else if (event.key === "ArrowDown" && index < items.length - 1) {
      items[index + 1].insertAdjacentElement("afterend", item)
      item.focus()
      this.#save()
      this.#announce(`Moved to position ${index + 2}`)
    }
  }

  #save() {
    const ids = [...this.element.querySelectorAll("[data-sortable-id]")]
      .map(item => item.dataset.sortableId)

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({ ordered_ids: ids })
    })
  }

  #announce(message) {
    let region = document.getElementById("sortable-live-region")
    if (!region) {
      region = document.createElement("div")
      region.id = "sortable-live-region"
      region.setAttribute("aria-live", "polite")
      region.setAttribute("aria-atomic", "true")
      region.className = "sr-only"
      document.body.appendChild(region)
    }
    // Briefly clear then set so repeated moves are announced
    region.textContent = ""
    requestAnimationFrame(() => { region.textContent = message })
  }
}
