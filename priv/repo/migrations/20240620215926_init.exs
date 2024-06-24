defmodule PixelPlace.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:pixel, primary_key: false) do
      add :x, :integer, primary_key: true
      add :y, :integer, primary_key: true
      add :color, :integer
      add :discord_id, :integer
    end

    create table(:session, primary_key: false) do
      add :token, :string, primary_key: true
      add :access_token, :string
      add :refresh_token, :string
      add :expires_at, :utc_datetime
      add :discord_id, :integer
    end
  end
end
