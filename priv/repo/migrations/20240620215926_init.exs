defmodule PixelPlace.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:pixel, primary_key: false) do
      add :x, :integer, primary_key: true
      add :y, :integer, primary_key: true
      add :color, :integer
    end
  end
end
