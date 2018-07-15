defmodule Tanks.GameServer do
  alias Tanks.Entertainment.{Game, Room}
  alias Tanks.RoomStore
  alias TanksWeb.{GameChannel, RoomChannel}


## Interfaces
  @doc """
  spawn up a process to manage game state
  :: pid
  """
  def start(game, name) do
    # state is {name:, game: }
    # we use room name as our GenServer server name
    name = String.to_atom(name)
    GenServer.start(__MODULE__, {name, game}, name: name)
    Process.send(name, :auto_update_state, [])

    # broadcast to all connected sockets,
    # this is a good chance to implement game start countdown
    TanksWeb.Endpoint.broadcast!("room:#{name}", "gamestart", %{})
  end

## Server Implementations
  def init({name, game}) do
    {:ok, {name, game}}
  end

  # Game Loop:
  def handle_info(:auto_update_state, {servername, game}) do
    # IO.puts "@@@@@@@@@@@@@@@ auto_update_state called"

    # loop:
    Process.send_after(servername, :auto_update_state, 35) # 1000 / 20 = 50 => 20 FPS

    name = Atom.to_string(servername)
    clear_missiles = false
    # update missile trajectory
    if length(game.missiles) > 0 do
      clear_missiles = true
      # broadcast current state
      GameChannel.broadcast_state(game, name)
      # iterate to next state
      game = Game.next_state(game)
    end
    if clear_missiles, do: GameChannel.broadcast_state(game, name)


    # Handle game over situation
    if length(game.tanks) <= 1 && length(game.missiles) == 0 do
      # broadcast current state
      GameChannel.broadcast_state(game, name)
      # update room with Room.end_game
      room = Room.end_game(RoomStore.load(name))
      RoomStore.save(name, room)
      # broadcast to game about gameover, client should congrat winner and get back to room in 5 seconds.
      TanksWeb.Endpoint.broadcast!("game:#{name}", "gameover", %{game: Game.client_view(game)})
      IO.puts "I'm here 4"

      # wait for 5 seconds
      Process.sleep(5000)
      # broadcast to room, so that room get updated and render the room view
      IO.puts "I'm here 5"

      TanksWeb.Endpoint.broadcast!("room:#{name}", "update_room", %{room: RoomChannel.room_data(room)})
      # broadcast to list_rooms/homepage, so it can update new room status
      TanksWeb.Endpoint.broadcast("list_rooms", "rooms_status_updated", %{room: %{name: name, status: Room.get_status(room)}})

      # finally tell genserver process to stop
      {:stop, :normal, {servername, game}}
    else
      {:noreply, {servername, game}}
    end
  end

  @doc """
  :: game
  """
  def handle_call(:get_state, _from, {servername, game} = state) do
    {:reply, game, state}
  end

  def handle_call({:fire, player_id}, _, {servername, game}) do
    game = Game.fire(game, player_id)
    {:reply, game, {servername, game}}
  end

  def handle_call({:move, player_id, direction}, _, {servername, game}) do
    game = Game.move(game, player_id, direction)
    {:reply, game, {servername, game}}
  end

end
