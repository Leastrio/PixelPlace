defmodule PixelPlaceWeb.IndexLive do
  use PixelPlaceWeb, :live_view
  import Bitwise

  @impl true
  def render(assigns) do
    ~H"""
    <div id="loadingScreen" class="fixed inset-0 bg-white z-50 flex flex-col items-center justify-center" phx-update="ignore">
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
        <br id="br-1" class="hidden">
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
      <div class="absolute top-0 right-0">
        <%= if @discord_id == nil do %>
          <button id="discordLogin" class="m-4 mb-0 bg-blurple p-4 rounded-lg shadow-xl font-bold text-white flex items-center">
            <svg class="size-8 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 127.14 96.36">
              <path fill="#fff" d="M107.7,8.07A105.15,105.15,0,0,0,81.47,0a72.06,72.06,0,0,0-3.36,6.83A97.68,97.68,0,0,0,49,6.83,72.37,72.37,0,0,0,45.64,0,105.89,105.89,0,0,0,19.39,8.09C2.79,32.65-1.71,56.6.54,80.21h0A105.73,105.73,0,0,0,32.71,96.36,77.7,77.7,0,0,0,39.6,85.25a68.42,68.42,0,0,1-10.85-5.18c.91-.66,1.8-1.34,2.66-2a75.57,75.57,0,0,0,64.32,0c.87.71,1.76,1.39,2.66,2a68.68,68.68,0,0,1-10.87,5.19,77,77,0,0,0,6.89,11.1A105.25,105.25,0,0,0,126.6,80.22h0C129.24,52.84,122.09,29.11,107.7,8.07ZM42.45,65.69C36.18,65.69,31,60,31,53s5-12.74,11.43-12.74S54,46,53.89,53,48.84,65.69,42.45,65.69Zm42.24,0C78.41,65.69,73.25,60,73.25,53s5-12.74,11.44-12.74S96.23,46,96.12,53,91.08,65.69,84.69,65.69Z"/>
            </svg>
            Login with Discord
          </button>
        <% end %>
        <div class="text-right">
          <div class="inline-block bg-white max-w-max m-4 mb-0 rounded-lg shadow-2xl pointer-events-auto">
            <p class="p-3 font-bold flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6 mr-2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
              </svg>
              Online: <%= @online_count %>
            </p>
          </div>
        </div>
        <div class="text-right">
          <div class="inline-block bg-white max-w-max m-4 rounded-lg shadow-2xl pointer-events-auto">
            <p id="coords" class="p-3 font-bold">(0, 0)</p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(:online_count, PixelPlaceWeb.Presence.online_count())

    if connected?(socket) do
      PixelPlaceWeb.Presence.track_user(socket.id)
      PixelPlaceWeb.Presence.subscribe()
      PixelPlaceWeb.Endpoint.subscribe("room:lobby")
      discord_id = get_in(PixelPlace.Session.get(session["session_token"]), [Access.key!(:discord_id)])
      socket = socket
        |> push_event("init_board", %{data: PixelPlace.Pixel.get_all(), authenticated: !is_nil(discord_id)})
        |> assign(:discord_id, discord_id)

      {:ok, socket}
    else
      {:ok, assign(socket, :discord_id, nil)}
    end
  end

  @impl true
  def handle_event("draw_pixel", %{"x" => x, "y" => y, "selectedColor" => [r, g, b]}, socket) do
    discord_id = socket.assigns.discord_id
    if is_nil(discord_id) do
      {:noreply, socket |> put_flash(:error, "You must login first to place a pixel!")}
    else
      color = (r <<< 16) + (g <<< 8) + b
      PixelPlace.Pixel.upsert_pixel(x, y, color, discord_id);
      PixelPlaceWeb.Endpoint.local_broadcast("room:lobby", "pixel", {x, y, [r, g, b], discord_id})
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{event: "pixel", payload: {x, y, color, discord_id}}, socket) do
    if discord_id == socket.assigns.discord_id do
      {:noreply, socket}
    else
      {:noreply, push_event(socket, "draw_pixel", %{x: x, y: y, color: color})}
    end
  end

  @impl true
  def handle_info({:online_count, count}, socket) do
    {:noreply, assign(socket, :online_count, count)}
  end
end
