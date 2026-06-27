import { Controller } from "@hotwired/stimulus"

// Manages bulk selection of table rows: a header "select all" checkbox and
// per-row checkboxes drive a live count. "Delete selected" is shown only when
// at least one row is selected; "Delete all" only when every row is selected.
export default class extends Controller {
  static targets = ["selectAll", "item", "submit", "deleteAll", "count"]

  connect() {
    this.update()
  }

  toggleAll() {
    this.itemTargets.forEach((item) => { item.checked = this.selectAllTarget.checked })
    this.update()
  }

  update() {
    const total = this.itemTargets.length
    const selected = this.itemTargets.filter((item) => item.checked).length

    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = selected > 0 && selected === total
      this.selectAllTarget.indeterminate = selected > 0 && selected < total
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.classList.toggle("hidden", selected === 0)
    }

    if (this.hasDeleteAllTarget) {
      this.deleteAllTarget.classList.toggle("hidden", !(total > 0 && selected === total))
    }

    if (this.hasCountTarget) {
      this.countTarget.textContent = selected === 0 ? "None selected" : `${selected} selected`
    }
  }
}
