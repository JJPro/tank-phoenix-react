defmodule TanksWeb.RoomChannel do
  use TanksWeb, :channel
  alias Tanks.Entertainment.{Room, Game}
  alias Tanks.Accounts
  alias Phoenix.PubSub

  def join("room:" <> name, payload, socket) do
    # IO.puts ">>>>>>>> join: room"
    # IO.puts ">>>>>>> payload: "
    # IO.inspect payload

    if authorized?(payload) do
      # create or restore room
      # return room to client
      room = Tanks.RoomStore.load(name) || Room.new(name, Accounts.get_user!(payload["uid"]))
      socket = socket
      |> assign(:name, name)
      |> assign(:room, room)

      {:ok, %{room: room_data(room)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ready", %{"uid" => uid}, socket) do
    IO.puts ">>>>> ready"
    # IO.inspect socket.assigns.room

    user = Accounts.get_user!(uid)
    room = Room.player_ready(socket.assigns.room, user)
    Tanks.RoomStore.save(room.name, room)

    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}

    {:noreply, socket}
  end

  def handle_in("cancel", %{"uid" => uid}, socket) do
    user = Accounts.get_user!(uid)
    room = Room.player_cancel_ready(socket.assigns.room, user)
    Tanks.RoomStore.save(room.name, room)
    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}

    {:noreply, socket}
  end

  def handle_in("enter", %{"uid" => uid}, socket) do
    user = Accounts.get_user!(uid)
    room = Room.add_player(socket.assigns.room, user)
    Tanks.RoomStore.save(room.name, room)

    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}
    # broadcast to home page viewers (list_rooms_channel.ex)
    TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: room.name, status: Room.get_status(room)}})

    {:noreply, socket}
  end


  def handle_in("leave", %{"uid" => uid}, socket) do
    user = Accounts.get_user!(uid)
    room = Room.remove_player(socket.assigns.room, user)
    Tanks.RoomStore.save(room.name, room)

    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}
    # broadcast to home page viewers (list_rooms_channel.ex)
    TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: room.name, status: Room.get_status(room)}})

    {:noreply, socket}
  end

  def handle_in("kickout", %{"uid" => uid} = payload, socket) do
    handle_in("leave", payload, socket)
  end

  def handle_in("start", payload, socket) do
    room = Room.start_game(socket.assigns.room)
    Tanks.RoomStore.save(room.name, room)
    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}
    # broadcast to home page viewers (list_rooms_channel.ex)
    TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: room.name, status: Room.get_status(room)}})

    {:noreply, socket}
  end

  def handle_in("end", payload, socket) do
    room = Room.end_game(socket.assigns.room)
    Tanks.RoomStore.save(room.name, room)
    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}
    # broadcast to home page viewers (list_rooms_channel.ex)
    TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: room.name, status: Room.get_status(room)}})

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  @doc """
  format player object to json format
  player is: %{owner?: bool, ready?: bool, user: %User{}}
  :: %{name: string, id: int, owner?: bool, ready?: bool}
  """
  defp player_data(player) do
    %{
      name: player.user.name,
      id: player.user.id,
      owner?: player.owner?,
      ready?: player.ready?,
    }
  end

  @doc """
  format room object to json format
  """
  defp room_data(room) do
    # IO.puts '+++++++++++'
    # IO.inspect room

    %{
      room | players: Enum.map(room.players, fn p -> player_data(p) end)
    }
  end
end
