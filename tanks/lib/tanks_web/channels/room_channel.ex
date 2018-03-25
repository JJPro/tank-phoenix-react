defmodule TanksWeb.RoomChannel do
  use TanksWeb, :channel
  alias Tanks.Entertainment.{Room, Game}
  alias Tanks.RoomStore
  alias Tanks.Accounts
  alias Phoenix.PubSub

  def join("room:" <> name, %{"uid" => uid} = payload, socket) do
    # IO.puts ">>>>>>>> join: room"
    # IO.puts ">>>>>>> payload: "
    # IO.inspect payload

    if authorized?(payload) do
      # create or restore room
      # return room to client

      room = if room = RoomStore.load(name) do
        room
      else
        # broadcast to home page viewers about new room
        TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: name, status: :open}})

        room = Room.new(name, Accounts.get_user!(uid))
        RoomStore.save(name, room)
        room
      end

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
    RoomStore.save(room.name, room)

    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}

    {:noreply, socket}
  end

  def handle_in("cancel", %{"uid" => uid}, socket) do
    user = Accounts.get_user!(uid)
    room = Room.player_cancel_ready(socket.assigns.room, user)
    RoomStore.save(room.name, room)
    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}

    {:noreply, socket}
  end

  def handle_in("enter", %{"uid" => uid}, socket) do
    IO.puts "<<<<<<<<< Enter"
    user = Accounts.get_user!(uid)
    case Room.get_status(socket.assigns.room) do
      :open ->
          room = Room.add_player(socket.assigns.room, user)
          RoomStore.save(room.name, room)

          # broadcast change to all players and observers
          broadcast socket, "update_room", %{room: room_data(room)}
          # broadcast to home page viewers (list_rooms_channel.ex)
          TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: room.name, status: Room.get_status(room)}})

          # {:noreply, socket}
          {:reply, :ok, socket}
          # {:reply, {:error, %{reason: "Room is full."}}, socket}
      :full -> {:reply, {:error, %{reason: "Room is full."}}, socket}
      :playing -> {:reply, {:error, %{reason: "Game already stared."}}, socket}
    end
  end


  def handle_in("leave", %{"uid" => uid}, socket) do
    user = Accounts.get_user!(uid)
    {status, room} = Room.remove_player(socket.assigns.room, user)
    case status do
      :ok ->  RoomStore.save(room.name, room)
              # broadcast change to all players and observers
              broadcast socket, "update_room", %{room: room_data(room)}
              # broadcast to home page viewers (list_rooms_channel.ex)
              TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: room.name, status: Room.get_status(room)}})
      :error -> RoomStore.delete(socket.assigns.room.name)
                broadcast socket, "update_room", %{room: %{name: socket.assigns.room.name, players: []}}
                TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: socket.assigns.room.name, status: :deleted}})
    end

    {:noreply, socket}
  end

  def handle_in("kickout", %{"uid" => uid} = payload, socket) do
    handle_in("leave", payload, socket)
  end

  def handle_in("start", _payload, socket) do
    IO.puts ">>>>>>>> Start Game"
    {status, room} = Room.start_game(socket.assigns.room)
    case status do
      :ok ->
        RoomStore.save(room.name, room)
        # broadcast change to all players and observers
        broadcast socket, "update_room", %{room: room_data(room)}
        # broadcast to home page viewers (list_rooms_channel.ex)
        TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: room.name, status: Room.get_status(room)}})

        {:noreply, socket}
      :error ->
        {:reply, {:error, %{reason: "At least two players are required to start a game."}}, socket}
    end
  end

  def handle_in("end", payload, socket) do
    room = Room.end_game(socket.assigns.room)
    RoomStore.save(room.name, room)
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
      is_owner: player.owner?,
      is_ready: player.ready?,
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
