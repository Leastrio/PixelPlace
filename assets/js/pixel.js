const config = {
  width: 250,
  height: 250
}

const view = {
  x: (window.innerWidth - config.width * 5) / 2,
  y: (window.innerHeight - config.height * 5) / 2,
  scale: 5
}

const colors = {
  "red": [252, 165, 165],
  "orange": [253, 186, 116],
  "yellow": [253, 224, 71],
  "green": [134, 239, 172],
  "blue": [147, 197, 253],
  "purple": [216, 180, 254],
  "white": [255, 255, 255],
  "black": [0, 0, 0]
}

let canvas, ctx, border, coords, selectedHex, selectedBubble, colorPicker;
let prevX = 0;
let prevY = 0;
let isPanning = false;
let selectedColor = [0, 0, 0];

const imgCanvas = document.createElement('canvas');
imgCanvas.width = config.width;
imgCanvas.height = config.height;
const imgctx = imgCanvas.getContext('2d');

function resizeCanvas() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}

export function draw() {
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.fillStyle = '#eeeeee';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.imageSmoothingEnabled = false;
  ctx.setTransform(view.scale, 0, 0, view.scale, view.x, view.y);
  ctx.drawImage(imgCanvas, 0, 0);
}

function getMousePos(evt) {
  const rect = canvas.getBoundingClientRect();
  const scale = view.scale;

  const canvasX = (evt.clientX - rect.left - view.x) / scale;
  const canvasY = (evt.clientY - rect.top - view.y) / scale;

  new_pos = {
    x: Math.floor(canvasX),
    y: Math.floor(canvasY)
  }
    
  if (new_pos.x >= 0 && new_pos.x < config.width && new_pos.y >= 0 && new_pos.y < config.height) {
    coords.innerHTML = `(${new_pos.x}, ${new_pos.y})`
  }
  return new_pos;
}

function drawBorder(mousePos) {
  const scale = view.scale;

  if (mousePos.x < 0 || mousePos.x > config.width - 1 || mousePos.y < 0 || mousePos.y > config.height - 1 || view.scale <= 7) {
    border.style.display = 'none';
  } else {
    border.style.left = (mousePos.x * scale + view.x) + 'px';
    border.style.top = (mousePos.y * scale + view.y) + 'px';
    border.style.width = scale + 'px';
    border.style.height = scale + 'px';
    border.style.display = 'block';
  }
}

export function drawPixel(x, y, color) {
  setPixel(x, y, color);
  draw();
}

export function setPixel(x, y, color) {
  const imageData = ctx.createImageData(1, 1);
  imageData.data[0] = color[0];
  imageData.data[1] = color[1];
  imageData.data[2] = color[2];
  imageData.data[3] = 255;

  imgctx.putImageData(imageData, x, y);
}

function updatePanning(evt) {
  const localX = evt.clientX;
  const localY = evt.clientY;

  view.x += localX - prevX;
  view.y += localY - prevY;

  prevX = localX;
  prevY = localY;

  draw()
}

function clamp(num) {
  return Math.max(0.50, Math.min(num, 40));
}

function updateZooming(evt) {
  border.style.display = 'none';
  const oldScale = view.scale;
  const oldX = view.x;
  const oldY = view.y;

  const localX = evt.clientX;
  const localY = evt.clientY;

  const delta = evt.deltaY < 0 ? 1.1 : 0.9;

  const newScale = clamp(view.scale * delta);
  const newX = localX - (localX - oldX) * (newScale / oldScale);
  const newY = localY - (localY - oldY) * (newScale / oldScale);

  view.x = newX;
  view.y = newY;
  view.scale = newScale;

  draw();
}

function initCanvas() {
  imgctx.fillStyle = "#ffffff";
  imgctx.fillRect(0, 0, imgCanvas.width, imgCanvas.height);
  imgctx.fillStyle = "#000000";
  imgctx.fillRect(0, 0, imgCanvas.width, 1);
  imgctx.fillRect(0, imgCanvas.height - 1, imgCanvas.width, 1);
  imgctx.fillRect(0, 0, 1, imgCanvas.height);
  imgctx.fillRect(imgCanvas.width - 1, 0, 1, imgCanvas.height);
}

export function startPixelCanvas(lv) {
  canvas = document.getElementById('drawingCanvas');
  ctx = canvas.getContext('2d');
  border = document.getElementById('pixelBorder');
  coords = document.getElementById('coords');
  selectedHex = document.getElementById('hex');
  selectedBubble = document.getElementById('bubble');
  colorPicker = document.getElementById('colorPicker');
  resizeCanvas();
  initCanvas();
  draw();

  window.addEventListener('resize', () => {
    resizeCanvas();
    draw();
  });

  canvas.addEventListener('contextmenu', (evt) => {
    evt.preventDefault();
  });

  canvas.addEventListener('mousedown', (evt) => {
    if (evt.button === 0) {
      const pos = getMousePos(evt);
      const x = pos.x
      const y = pos.y
      if (x >= 0 && x < config.width && y >= 0 && y < config.height) {
        drawPixel(x, y, selectedColor);
        lv.pushEvent("draw_pixel", {x, y, selectedColor});
      }
    } else if (evt.button == 1) {
      prevX = evt.clientX;
      prevY = evt.clientY;
      isPanning = true;
    }
  });

  canvas.addEventListener('mouseup', (evt) => {
    if (evt.button == 1) {
      isPanning = false;
      canvas.style.cursor = 'default';
    }
  })

  canvas.addEventListener('mousemove', (evt) => {
    if (isPanning) {
      canvas.style.cursor = "grab";
      border.style.display = "none";
      updatePanning(evt);
    } else {
      const pixel_pos = getMousePos(evt);
      drawBorder(pixel_pos);
    }
  })

  canvas.addEventListener("wheel", (evt) => {
    updateZooming(evt);
  })

  canvas.addEventListener('touchstart', (evt) => {
    if (evt.touches.length === 1) {
      prevX = evt.touches[0].clientX;
      prevY = evt.touches[0].clientY;
      isPanning = true;
    } else {
      evt.preventDefault();
    }
  });

  canvas.addEventListener('touchmove', (evt) => {
    if (evt.touches.length === 1 && isPanning) {
      border.style.display = 'none';
      const localX = evt.touches[0].clientX;
      const localY = evt.touches[0].clientY;

      view.x += localX - prevX;
      view.y += localY - prevY;

      prevX = localX;
      prevY = localY;

      draw();
    } else {
      evt.preventDefault();
    }
  });

  canvas.addEventListener('touchend', (evt) => {
    if (evt.touches.length === 0) {
      isPanning = false;
    }
  });

  document.getElementById('zoomIn').addEventListener("click", () => {
    updateZooming({clientX: window.innerWidth / 2, clientY: window.innerHeight / 2, deltaY: -0.1});
  });
  document.getElementById('zoomOut').addEventListener("click", () => {
    updateZooming({clientX: window.innerWidth / 2, clientY: window.innerHeight / 2, deltaY: 1.1});
  });

  selectedBubble.addEventListener("click", () => {
    colorPicker.click()
  })

  colorPicker.addEventListener("change", () => {
    const color = parseHex(colorPicker.value);

    selectedColor = color;
    selectedBubble.style.backgroundColor = `rgb(${color[0]}, ${color[1]}, ${color[2]})`
    selectedHex.value = colorPicker.value.toUpperCase();
  })

  selectedHex.addEventListener("change", () => {
    selectedHex.blur();
    const color = parseHex(selectedHex.value);
    if (Number.isNaN(color)) {
      selectedHex.value = "#000000";
      selectedBubble.style.backgroundColor = "rgb(0, 0, 0)";
      selectedColor = [0, 0, 0];
      colorPicker.value = "#000000";
    } else {
      const hex = rgbToHex(color);
      selectedHex.value = hex.toUpperCase();
      selectedBubble.style.backgroundColor = `rgb(${color[0]}, ${color[1]}, ${color[2]})`;
      selectedColor = color;
      colorPicker.value = hex;
    }
  })

  for (const [color, rgb] of Object.entries(colors)) {
    document.getElementById(color).addEventListener("click", () => {
      const hex = rgbToHex(rgb).toUpperCase();
      selectedColor = rgb;
      selectedBubble.style.backgroundColor = `rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})`
      selectedHex.value = hex;
      colorPicker.value = hex;
    });
  }

  const toggleSwatches = document.getElementById('toggleSwatches');
  const swatches = document.getElementById('swatches');
  const arrowIcon = document.getElementById('arrowIcon');

  // TODO: Fix this jank (tbf this entire file is jank)
  const br1 = document.getElementById('br-1');

  let swatchesVisible = false;

  toggleSwatches.addEventListener('click', () => {
    swatchesVisible = !swatchesVisible;
    if (swatchesVisible) {
      swatches.classList.remove('hidden');
      swatches.classList.add('inline-block');
      arrowIcon.classList.add('rotate-180');
      br1.classList.remove('hidden');
    } else {
      swatches.classList.remove('inline-block');
      swatches.classList.add('hidden');
      arrowIcon.classList.remove('rotate-180');
      br1.classList.add('hidden');
    }
  });
}

function parseHex(hex) {
  hex = hex.replace("#", "")
  if (hex.length == 3) {
    hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2]
  }

  const color = parseInt(hex, 16);

  const red = (color >> 16) & 0xFF;
  const green = (color >> 8) & 0xFF;
  const blue = color & 0xFF;

  return [red, green, blue];
}

function rgbToHex(color) {
  return "#" + (1 << 24 | color[0] << 16 | color[1] << 8 | color[2]).toString(16).slice(1);
}
