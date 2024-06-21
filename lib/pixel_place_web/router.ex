defmodule PixelPlaceWeb.Router do
  use PixelPlaceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PixelPlaceWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", PixelPlaceWeb do
    pipe_through :browser

    live "/", IndexLive
  end
end
