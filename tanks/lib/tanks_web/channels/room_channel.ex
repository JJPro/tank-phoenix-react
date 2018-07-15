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
    # IO.inspect self, label: ">>>>>>>>> PID of room channel"

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
      # |> assign(:room, room)

      {:ok, %{room: room_data(room)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ready", %{"uid" => uid}, %{assigns: %{name: name}} = socket) do
    # IO.puts ">>>>> ready"

    user = Accounts.get_user!(uid)
    room = Room.player_ready( RoomStore.load(name), user )


    RoomStore.save(name, room)
    # socket = assign(socket, :room, room)

    # IO.inspect %{user: user.id, new_room: length(room.players)}

    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}

    {:noreply, socket}
  end

  def handle_in("cancel", %{"uid" => uid}, %{assigns: %{name: name}} = socket) do
    user = Accounts.get_user!(uid)
    room = Room.player_cancel_ready(RoomStore.load(name), user)
    RoomStore.save(name, room)
    # socket = assign(socket, :room, room)
    # broadcast change to all players and observers
    broadcast socket, "update_room", %{room: room_data(room)}

    {:noreply, socket}
  end

  def handle_in("enter", %{"uid" => uid}, %{assigns: %{name: name}} = socket) do
    # IO.puts "<<<<<<<<< Enter"
    user = Accounts.get_user!(uid)
    room = RoomStore.load(name)
    case Room.get_status(room) do
      :open ->
          room = Room.add_player(room, user)
          RoomStore.save(name, room)

          # broadcast change to all players and observers
          broadcast socket, "update_room", %{room: room_data(room)}
          # broadcast to home page viewers (list_rooms_channel.ex)
          TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: name, status: Room.get_status(room)}})

          {:noreply, socket}
      :full ->
        if Room.get_player_from_user(room, user) do
          # user rejoin after disconnect
          {:noreply, socket}
        else
          {:reply, {:error, %{reason: "Room is full."}}, socket}
        end
      :playing ->
        if Room.get_player_from_user(room, user) do
          # user rejoin after disconnect
          {:noreply, socket}
        else
          {:reply, {:error, %{reason: "Game already stared."}}, socket}
        end
    end
  end


  def handle_in("leave", %{"uid" => uid}, %{assigns: %{name: name}} = socket) do
    user = Accounts.get_user!(uid)
    # IO.puts ">>>>>>>>>>> Leave"
    # IO.puts "remove from room: "
    # IO.inspect socket.assigns.room
    # IO.puts "user: "
    # IO.inspect user
    {status, room} = Room.remove_player(RoomStore.load(name), user)
    case status do

      :ok ->    RoomStore.save(name, room)
                # broadcast change to all players and observers
                # socket = assign(socket, :room, room)
                broadcast socket, "update_room", %{room: room_data(room)}
                # broadcast to home page viewers (list_rooms_channel.ex)
                TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: name, status: Room.get_status(room)}})

      :last_player -> RoomStore.delete(name)
                # socket = assign(socket, :room, nil)
                broadcast socket, "update_room", %{room: %{name: name, players: []}}
                broadcast socket, "all_exit_room", %{}
                TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: name, status: :deleted}})

                # delete chat history to this room as well.
                Tanks.RoomStore.delete("chat:#{name}")
      :no_exist ->

    end

    {:noreply, socket}
  end

  def handle_in("kickout", %{"uid" => uid} = payload, socket) do
    handle_in("leave", payload, socket)
  end

  def handle_in("start", _payload, %{assigns: %{name: name}} = socket) do
    # IO.puts ">>>>>>>> Start Game"
    {status, room} = Room.start_game(RoomStore.load(name))
    case status do
      :ok ->
        RoomStore.save(room.name, room)
        # socket = assign(socket, :room, room)
        # broadcast change to all players and observers
        broadcast socket, "update_room", %{room: room_data(room)}
        # broadcast to home page viewers (list_rooms_channel.ex)
        TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: name, status: :playing}})

        {:noreply, socket}
      :error ->
        {:reply, {:error, %{reason: "At least two players are required to start a game."}}, socket}
    end
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
      tank_thumbnail: player.tank_thumbnail,
    }
  end

  @doc """
  format room object to json format
  """
  def room_data(room) do
    # IO.puts '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
    # IO.inspect %{room: room}
    %{
      name: room.name,
      players: Enum.map(room.players, fn p -> player_data(p) end),
      is_playing: room.playing?,
    }
  end
end
