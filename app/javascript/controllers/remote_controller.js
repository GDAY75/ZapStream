import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="remote"
export default class extends Controller {

  zap() {

    const display = document.getElementById("display-movie");

    display.innerHTML = `
      <video autoplay muted loop style="width: 100%;">
        <source src="/videos/screen-wait.mp4" type="video/mp4">
        Your browser does not support the video tag.
      </video>
    `;

    fetch("/pick_movie", {
    method: "POST",
    headers: {
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
    }
    })
    .then(response => response.text())
    .then(data => {
      setTimeout(() => {
        display.innerHTML = data;
      }, 1000);
    })
  }
}
