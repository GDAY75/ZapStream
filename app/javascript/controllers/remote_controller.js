import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="remote"
export default class extends Controller {

  zap() {
    const netflixButton = document.getElementById("netflix-button");
    const isNetflixActive = netflixButton.classList.contains("active");

    fetch("/pick_movie", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ filter: isNetflixActive ? "Netflix" : null })
    })
    .then(response => response.text())
    .then(data => {
      document.getElementById("display-movie").innerHTML = data;
    });
  }


  toggleNetflix(event) {
    const button = event.currentTarget;
    button.classList.toggle("active");
  }
}
