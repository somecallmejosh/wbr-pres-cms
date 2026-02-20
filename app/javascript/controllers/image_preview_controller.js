import { Controller } from "@hotwired/stimulus"

// Shows a preview of the selected image when choosing an image for an event.
// Attach to a wrapper containing a <select> and an <img> preview element.
//
// Usage:
//   data-controller="image-preview"
//   data-action="change->image-preview#update" on the <select>
//   data-image-preview-target="select" on the <select>
//   data-image-preview-target="preview" on the <img>
//   data-image-url="https://..." on each <option>
export default class extends Controller {
  static targets = ["select", "preview"]

  update() {
    const selected = this.selectTarget.selectedOptions[0]
    const url = selected?.dataset?.imageUrl

    if (url) {
      this.previewTarget.src = url
      this.previewTarget.hidden = false
    } else {
      this.previewTarget.hidden = true
    }
  }
}
