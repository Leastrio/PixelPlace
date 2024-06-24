defmodule PixelPlaceWeb.PageController do
  use PixelPlaceWeb, :controller

  def login(conn, _params) do
    conn
    |> redirect(external: PixelPlace.Discord.oauth_url())
  end

  def authorize(conn, %{"code" => code}) do
    token = :crypto.strong_rand_bytes(32) |> Base.encode64()
    with %{status: 200, body: resp} <- PixelPlace.Discord.get_access_token(code),
          {:ok, _} <- PixelPlace.Session.upsert(token, resp)
    do
      conn
      |> put_session(:session_token, token)
      |> redirect(to: "/")
    else
      _ -> redirect(conn, to: "/")
    end
  end

  def authorize(conn, _params) do
    conn
    |> put_flash(:error, "An error occurred when authorizing..")
    |> redirect(to: "/")
  end
end
