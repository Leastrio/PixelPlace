defmodule PixelPlaceWeb.IndexLive do
  use PixelPlaceWeb, :live_view
  import Bitwise

  @impl true
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-white z-50 flex flex-col items-center justify-center">
      <p class="mb-3">Loading pixels...</p>
      <p id="loading" class="font-black"></p>
    </div>
    <div class="relative touch-none select-none">
      <canvas id="drawingCanvas" phx-hook="Canvas" phx-update="ignore" class="block"></canvas>
      <span id="pixelBorder" class="border border-black absolute pointer-events-none hidden"></span>
      <div class="absolute top-0 pointer-events-none">
        <div class="bg-white m-4 rounded-lg shadow-2xl flex items-center pointer-events-auto">
          <input id="colorPicker" type="color" class="hidden">
          <button id="bubble" class="w-12 m-3 bg-black p-4 rounded-lg shadow-xl"></button><br>
          <input id="hex" class="w-24 font-bold focus:outline-none" maxlength="7" minlength="3" value="#000000">
        </div>
        <div class="inline-block max-w-22 sm:hidden m-4 mt-0 bg-white shadow-xl rounded-lg pointer-events-auto">
          <button id="toggleSwatches" class="w-12 m-3">
            <svg id="arrowIcon" class="w-6 h-6 mx-auto transition transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </button>
        </div>
        <br id="br-1" class="hidden sm:block">
        <div id="swatches" class="bg-white m-4 mt-0 rounded-lg shadow-2xl pointer-events-auto hidden sm:inline-block">
          <button id="red" class="w-12 m-3 bg-red-300 p-4 rounded-lg shadow-xl"></button><br>
          <button id="orange" class="w-12 m-3 bg-orange-300 p-4 rounded-lg shadow-xl"></button><br>
          <button id="yellow" class="w-12 m-3 bg-yellow-300 p-4 rounded-lg shadow-xl"></button><br>
          <button id="green" class="w-12 m-3 bg-green-300 p-4 rounded-lg shadow-xl"></button><br>
          <button id="blue" class="w-12 m-3 bg-blue-300 p-4 rounded-lg shadow-xl"></button><br>
          <button id="purple" class="w-12 m-3 bg-purple-300 p-4 rounded-lg shadow-xl"></button><br>
          <button id="white" class="w-12 m-3 bg-white p-4 rounded-lg shadow-xl ring-1 ring-slate-200"></button><br>
          <button id="black" class="w-12 m-3 bg-black p-4 rounded-lg shadow-xl"></button><br>
        </div>
        <br>
        <div class="inline-block bg-white m-4 mt-0 rounded-lg shadow-2xl pointer-events-auto">
          <button id="zoomIn" class="w-12 m-3">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" />
            </svg>
          </button><br><hr class="border">
          <button id="zoomOut" class="w-12 m-3">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM13 10H7" />
            </svg>
          </button>
        </div>
      </div>
      <div class="absolute top-0 right-0 bg-white m-4 rounded-lg shadow-2xl pointer-events-auto">
          <p id="coords" class="p-3 font-bold">(0, 0)</p>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    PixelPlaceWeb.Endpoint.subscribe("room:lobby")
    {:ok, push_event(socket, "init_board", %{data: PixelPlace.Pixel.get_all()})}
  end

  @impl true
  def handle_event("draw_pixel", %{"x" => x, "y" => y, "selectedColor" => [r, g, b]}, socket) do
    color = (r <<< 16) + (g <<< 8) + b
    PixelPlace.Pixel.upsert_pixel(x, y, color);
    PixelPlaceWeb.Endpoint.broadcast("room:lobby", "pixel", {x, y, [r, g, b]})
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "pixel", payload: {x, y, color}}, socket) do
    {:noreply, push_event(socket, "draw_pixel", %{x: x, y: y, color: color})}
  end
end
