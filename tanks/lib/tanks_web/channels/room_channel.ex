defmodule TanksWeb.RoomChannel do
  use TanksWeb, :channel
  alias Tanks.Entertainment.{Room, Game}

  def join("room:" <> name, payload, socket) do
    IO.puts ">>>>>>>> join: room"
    IO.puts ">>>>>>> payload: "
    IO.inspect payload

    if authorized?(payload) do
      # create or restore room
      # return room to client
      room = Tanks.RoomStore.load(name) || Room.new(name, payload.user)
      socket = socket
      |> assign(:name, name)
      |> assign(:room, room)
      {:ok, %{players: room.players}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ready", %{"user" => user}, socket) do
    room = Room.make_ready(socket.assgins[:room], user)
    Tanks.RoomStore.save(room.name, room)
    broadcast socket, "update_room", %{room: room}
    {:noreply, socket}
  end

  def handle_in("cancel", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("leave", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("kickout", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("start", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
