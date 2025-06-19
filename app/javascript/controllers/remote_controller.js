import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [];

  connect() {
    this.poweredOn = true;
  }

  togglePower() {
    const monitorContainer = document.getElementById("monitor-container");
    const monitorScreen = document.getElementById("monitor-screen");
    const display = document.getElementById("display-movie");

    this.poweredOn = !this.poweredOn;

    if (!this.poweredOn) {
      monitorContainer.classList.add("off");
      monitorScreen.classList.add("power-off"); // 💥 Ajout ici pour lancer l'animation
      display.innerHTML = "";
    } else {
      monitorContainer.classList.remove("off");
      monitorScreen.classList.remove("power-off"); // 🔄 Enlève l'animation au rallumage
    }
  }

  zap() {
    if (!this.poweredOn) return; // Ne fait rien si la télé est éteinte

    const display = document.getElementById("display-movie");

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

  toggleProvider(event) {
    if (!this.poweredOn) return;
    const button = event.currentTarget;
    button.classList.toggle("active");
  }
}
