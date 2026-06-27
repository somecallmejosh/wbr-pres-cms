import { Controller } from "@hotwired/stimulus"

// Live thumbnail previews for a multi-file image input, shown before upload.
//
// Backs the input with a DataTransfer so the previewed set IS the set that
// uploads — photos can be added in batches and removed individually, and the
// input's FileList always matches the thumbnails on screen.
export default class extends Controller {
  static targets = ["input", "preview", "list", "count", "template"]

  connect() {
    this.files = []
    this.urls = []
  }

  disconnect() {
    this.#revoke()
  }

  // change-> on the input: fold the newly chosen photos into our set.
  add() {
    for (const file of this.inputTarget.files) {
      if (file.type.startsWith("image/") && !this.#has(file)) this.files.push(file)
    }
    this.#commit()
  }

  // Drop one photo from the pending set.
  remove(event) {
    const tile = event.target.closest("[data-tile]")
    const index = [...this.listTarget.children].indexOf(tile)
    if (index > -1) {
      this.files.splice(index, 1)
      this.#commit()
    }
  }

  // Push our set back onto the input, then repaint.
  #commit() {
    const data = new DataTransfer()
    this.files.forEach(file => data.items.add(file))
    this.inputTarget.files = data.files
    this.#render()
  }

  #render() {
    this.#revoke()
    this.listTarget.replaceChildren()

    this.files.forEach(file => {
      const url = URL.createObjectURL(file)
      this.urls.push(url)

      const tile = this.templateTarget.content.firstElementChild.cloneNode(true)
      tile.querySelector("[data-preview-img]").src = url
      tile.querySelector("[data-preview-name]").textContent = file.name
      this.listTarget.appendChild(tile)
    })

    const count = this.files.length
    this.previewTarget.classList.toggle("hidden", count === 0)
    if (this.hasCountTarget) this.countTarget.textContent = count
  }

  #has(file) {
    return this.files.some(f =>
      f.name === file.name && f.size === file.size && f.lastModified === file.lastModified)
  }

  #revoke() {
    this.urls.forEach(url => URL.revokeObjectURL(url))
    this.urls = []
  }
}
