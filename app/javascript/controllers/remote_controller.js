import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [];

  connect() {
    this.poweredOn = true;
  }

  togglePower() {
    const monitorContainer = document.getElementById("monitor-container");
    const monitorScreen = document.getElementById("monitor-screen");
    const display = document.getElementById("display-media");

    this.poweredOn = !this.poweredOn;

    // Sélecteurs des boutons providers et médias
    const providerButtons = this.element.querySelectorAll(".button-square");
    const mediaButtons = this.element.querySelectorAll(".button-rectangle");

    if (!this.poweredOn) {
      monitorContainer.classList.add("off");
      monitorScreen.classList.add("power-off");
      display.innerHTML = "";

      // Retirer la classe active à tous les boutons
      providerButtons.forEach(btn => btn.classList.remove("active"));
      mediaButtons.forEach(btn => btn.classList.remove("active"));
    } else {
      monitorContainer.classList.remove("off");
      monitorScreen.classList.remove("power-off");

      // Ne pas réactiver les boutons : on laisse tout désactivé comme au démarrage
    }
  }


  zap() {
    if (!this.poweredOn) return; // Ne fait rien si la télé est éteinte

    const screen = document.getElementById("monitor-screen");
    const display = document.getElementById("display-media");

    // Ajoute une vidéo dans monitor-screen (mais en dehors de #display-media)
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
    loaderVideo.style.filter = "saturate(80%) contrast(90%)";
    loaderVideo.classList.add("loading-video");

    // Create and append color overlay
    const overlay = document.createElement("div");
    overlay.className = "animation-color-overlay";

    screen.appendChild(loaderVideo);
    screen.appendChild(overlay);

    // Providers
    const activeButtons = this.element.querySelectorAll(".button-square.active");
    const selectedProviders = Array.from(activeButtons).map(btn => btn.dataset.providerName);

    // Media
    const activeMediaButtons = this.element.querySelectorAll(".button-rectangle.active");
    const selectedMedia = Array.from(activeMediaButtons).map(btn => btn.dataset.mediaName);

    // Decide endpoint: if exactly one media, respect it; otherwise random
    let endpoint = null;
    if (selectedMedia.length === 1) {
      endpoint = selectedMedia[0] === "movies" ? "/pick_movie" : "/pick_serie";
    } else {
      endpoint = Math.random() < 0.5 ? "/pick_movie" : "/pick_serie";
    }

    fetch(endpoint, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        providers: selectedProviders,
        media: selectedMedia
      })
    })
    .then(response => response.text())
    .then(data => {
      setTimeout(() => {
        loaderVideo.remove();
        overlay.remove();
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
