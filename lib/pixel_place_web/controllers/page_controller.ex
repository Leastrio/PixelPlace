defmodule PixelPlaceWeb.PageController do
  use PixelPlaceWeb, :controller

  def login(conn, _params) do
    conn
    |> put_session(:test, 1)
    |> redirect(to: "/")
  end
end
