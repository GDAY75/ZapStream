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

    // Providers
    const activeButtons = this.element.querySelectorAll(".button-square.active");
    const selectedProviders = Array.from(activeButtons).map(btn => btn.dataset.providerName);

    // Media
    const activeMediaButtons = this.element.querySelectorAll(".button-rectangle.active");
    let endpoint = null;
    if (activeMediaButtons.length === 1) {
      const mediaName = activeMediaButtons[0].dataset.mediaName;
      endpoint = mediaName === "movies" ? "/pick_movie" : "/pick_serie";
    } else {
      // None or both selected: pick randomly
      endpoint = Math.random() < 0.5 ? "/pick_movie" : "/pick_serie";
    }

    fetch(endpoint, {
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
        loaderVideo.remove();
        display.innerHTML = data;
      }, 1000);
    });
  }

  toggleProvider(event) {
    if (!this.poweredOn) return;
    const providerButton = event.currentTarget;
    providerButton.classList.toggle("active");
  }

  toggleMedia(event) {
    if (!this.poweredOn) return;
    const mediaButton = event.currentTarget;
    mediaButton.classList.toggle("active");
  }
}
