defmodule PixelPlace.Pixel do
  use Ecto.Schema
  import Ecto.Query, only: [from: 1]

  @derive {Jason.Encoder, only: [:x, :y, :color]}
  @primary_key false
  schema "pixel" do
    field :x, :integer, primary_key: true
    field :y, :integer, primary_key: true
    field :color, :integer
    field :discord_id, :integer
  end

  def get_all() do
    PixelPlace.Repo.all(from(p in __MODULE__))
  end

  def upsert_pixel(x, y, color, discord_id) do
    %__MODULE__{x: x, y: y, color: color, discord_id: discord_id}
    |> PixelPlace.Repo.insert(on_conflict: [set: [color: color, discord_id: discord_id]], conflict_target: [:x, :y])
  end
end
