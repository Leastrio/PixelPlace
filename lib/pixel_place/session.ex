defmodule PixelPlace.Session do
  use Ecto.Schema

  @primary_key false
  schema "session" do
    field :token, :string, primary_key: true
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime
    field :discord_id, :integer
  end

  def upsert(token, %{"access_token" => access, "expires_in" => exp, "refresh_token" => refresh}) do
    expires = 
      DateTime.now!("Etc/UTC") 
      |> DateTime.add(exp) 
      |> DateTime.truncate(:second)

    discord_id = String.to_integer(PixelPlace.Discord.fetch_id(access))

    %__MODULE__{token: token, access_token: access, refresh_token: refresh, expires_at: expires, discord_id: discord_id}
      |> PixelPlace.Repo.insert(on_conflict: [set: [access_token: access, refresh_token: refresh, expires_at: expires, discord_id: discord_id]], conflict_target: [:token])
  end

  def get(nil), do: nil
  def get(token) do
    PixelPlace.Repo.get_by(__MODULE__, token: token)
  end
end
