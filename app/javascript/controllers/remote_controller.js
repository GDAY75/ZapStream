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

    const screen = document.getElementById("monitor-screen");
    const display = document.getElementById("display-movie");

    // Ajoute une vidéo dans monitor-screen (mais en dehors de #display-movie)
    const loaderVideo = document.createElement("video");
    loaderVideo.src = "/videos/screen-wait3.mp4";
    loaderVideo.autoplay = true;
    loaderVideo.muted = true;
    loaderVideo.loop = true;
    loaderVideo.style.position = "absolute";
    loaderVideo.style.top = 0;
    loaderVideo.style.left = 0;
    loaderVideo.style.width = "100%";
    loaderVideo.style.height = "100%";
    loaderVideo.style.objectFit = "cover";
    loaderVideo.classList.add("loading-video");

    screen.appendChild(loaderVideo);

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
        // Retire la vidéo de loading
        loaderVideo.remove();

        // Injecte le contenu dans display-movie
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
