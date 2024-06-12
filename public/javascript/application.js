import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
window.Stimulus = Application.start()

Stimulus.register("habit", class extends Controller {
  static targets = [ "source" ]

  copy(event) {
    event.preventDefault()
    navigator.clipboard.writeText(this.sourceTarget.innerHTML)
  }
})