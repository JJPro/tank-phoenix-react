defmodule TanksWeb.ListRoomsChannel do
  @moduledoc """
  Channel for Listing Gaming Rooms

  join -> collect and send all game statuses
  """
  use TanksWeb, :channel
  alias Tanks.Entertainment.Room

  @doc """
  :: {:ok, %{rooms: list}}
  """
  def join("list_rooms", payload, socket) do
    IO.puts ">>>>>>> joining list rooms"
    if authorized?(payload) do
      # collect all rooms
      # get status of all rooms
      # return %{name: , status: }

      rooms =
        Tanks.RoomStore.list # get all rooms [%{name:, room:}]
        |> Enum.map(fn %{name: name, room: room} ->
          %{name: name, status: Room.get_status(room)} end)

      {:ok, %{rooms: rooms}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
