import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import { startPixelCanvas, setPixel, drawPixel, draw } from "./pixel.js" 

let Hooks = {}
Hooks.Canvas = {
  mounted() {
    this.handleEvent("init_board", ({data, authenticated}) => {
      startPixelCanvas(this, authenticated);
      const total = data.length;
      let loading = document.getElementById('loading');
      let completed = 0;
      data.forEach((pixel) => {
        const red = (pixel.color >> 16) & 0xFF;
        const green = (pixel.color >> 8) & 0xFF;
        const blue = pixel.color & 0xFF;

        setPixel(pixel.x, pixel.y, [red, green, blue])
        loading.innerHTML = `${++completed} / ${total}`
      });
      draw();
      loading.parentElement.style.display = 'none';
    })
    this.handleEvent("draw_pixel", ({x, y, color}) => {
      drawPixel(x, y, color);
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

topbar.config({barColors: {0: "#000000"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

liveSocket.connect()

window.liveSocket = liveSocket

