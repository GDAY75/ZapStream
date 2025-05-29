import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="remote"
export default class extends Controller {

  zap() {
    fetch("/pick_movie", {
    method: "POST",
    headers: {
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
    }
    })
    .then(response => response.text())
    .then(data => {
      document.getElementById("display-movie").innerHTML = data;
    })
  }
}
