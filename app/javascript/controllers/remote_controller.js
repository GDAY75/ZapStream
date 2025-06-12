import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="remote"
export default class extends Controller {

  toggleProvider(event) {
    const button = event.currentTarget;
    button.classList.toggle("active");
  }


  zap() {
    const display = document.getElementById("display-movie");

    // vidéo loading
    display.innerHTML = `
      <video autoplay muted loop style="width: 100%;">
        <source src="/videos/screen-wait.mp4" type="video/mp4">
        Your browser does not support the video tag.
      </video>
    `;

    const activeButtons = this.element.querySelectorAll(".button-square.active");
    const selectedProviders = Array.from(activeButtons).map(btn => btn.dataset.providerName);

    fetch("/pick_movie", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ providers: selectedProviders })
    })
    .then(response => response.text())
    .then(data => {
      setTimeout(() => {
        display.innerHTML = data;
      }, 1000);
    });
  }

}
