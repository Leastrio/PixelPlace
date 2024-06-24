defmodule PixelPlaceWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :pixel_place,
    pubsub_server: PixelPlace.PubSub

  @impl true
  def init(_opts) do
    {:ok, %{count: 0}}
  end

  @impl true
  def handle_metas(topic, %{joins: joins, leaves: leaves}, _presences, %{count: online}) do
    joins_count = joins |> Map.to_list() |> length()
    leaves_count = leaves |> Map.to_list() |> length()

    new_count = online + joins_count - leaves_count
    Phoenix.PubSub.local_broadcast(PixelPlace.PubSub, "proxy:#{topic}", {:online_count, new_count})
    {:ok, %{count: new_count}}
  end

  def track_user(id), do: track(self(), "online_users", id, %{})
  def subscribe(), do: Phoenix.PubSub.subscribe(PixelPlace.PubSub, "proxy:online_users")
  def online_count(), do: list("online_users") |> Map.to_list() |> length()

end
