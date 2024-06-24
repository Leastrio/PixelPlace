defmodule PixelPlace.Discord do
  def client_id, do: Application.get_env(:pixel_place, :discord)[:client_id]
  def client_secret, do: Application.get_env(:pixel_place, :discord)[:client_secret]
  def redirect_url, do: Application.get_env(:pixel_place, :discord)[:redirect_url]
  def oauth_url, do: Application.get_env(:pixel_place, :discord)[:oauth_url]
  def webhook_url, do: Application.get_env(:pixel_place, :discord)[:webhook_url]

  def get_access_token(code) do
    Req.post!(
      "https://discord.com/api/v10/oauth2/token",
      form: [grant_type: "authorization_code", code: code, redirect_uri: redirect_url()],
      auth: {:basic, "#{client_id()}:#{client_secret()}"}
    )
  end

  #def refresh_token(refresh_token) do
  #  Req.post!(
  #    "https://discord.com/api/v10/oauth2/token",
  #    form: [grant_type: "refresh_token", refresh_token: refresh_token],
  #    auth: {:basic, "#{@client_id}:#{@client_secret}"}
  #  )
  #end 

  def post_webhook(username) do
    Req.post(webhook_url(), json: %{content: "New user: #{username}"})
  end

  def fetch_id(access_token) do
    body = Req.get!("https://discord.com/api/v10/users/@me", headers: [authorization: "Bearer #{access_token}"]).body
    post_webhook(body["username"])

    body["id"]
  end
end
