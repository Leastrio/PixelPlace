defmodule PixelPlace.Repo do
  use Ecto.Repo,
    otp_app: :pixel_place,
    adapter: Ecto.Adapters.SQLite3
end
