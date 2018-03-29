defmodule TanksWeb.GameChannel do
  use TanksWeb, :channel

  alias Tanks.GameServer
  alias GenServer
  alias Tanks.Entertainment.Game

  @doc """
  1. retrieve game state from game_server process
  2. send back game state

  :: send back gameview, no broadcast needed
  """
  def join("game:"<>name, payload, socket) do

    if authorized?(payload) do
      # new game process is attached by room_channel
      name = String.to_atom(name)
      if GenServer.whereis(name) do
        game = GenServer.call(name, :get_state)
        {:ok, Game.client_view(game), assign(socket, :name, name)}
      else
        {:error, %{reason: "terminated"}}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc """
  get current game state from game_server process and send back to client:
    1. get state from game_server
    2. send state->gameview to client
  """
  def handle_in("get_state", _payload, %{assigns: %{name: name}} = socket) do
    game = GenServer.call(name, :get_state)
    if length(game.tanks) == 1 do
      broadcast socket, "gameover", %{}
    end
    {:reply, {:ok, Game.client_view(game)}, socket}
  end

  def handle_in("game_ended", _, %{assigns: %{name: name}} = socket) do
    TanksWeb.Endpoint.broadcast("room:#{name}", "gameover", %{})
    {:noreply, socket}
  end

  @doc """
  1. ask game_server to fire
  2. send state->gameview to client
  """
  def handle_in("fire", %{"uid" => uid}, %{assigns: %{name: name}} = socket) do
    # IO.puts ">>>>>>>>>>>>>>>>>>>>>>> FIREING <<<<<<<<<<<<<"
    # IO.inspect %{user: uid}
    game = GenServer.call(name, :get_state)
    player = Game.get_player_from_uid(game, uid)
    GenServer.cast(name, {:fire, player})
    # broadcast socket, "update_game", %{game: Game.client_view(game)}
    {:reply, {:ok, Game.client_view(game)}, socket}
  end

  @doc """
  1. ask game_server to move player
  2. send state->gameview to client
  """
  def handle_in("move", %{"uid" => uid, "direction" => direction}, %{assigns: %{name: name}} = socket) do
    game = GenServer.call(name, :get_state)
    player = Game.get_player_from_uid(game, uid)
    GenServer.cast(name, {:move, player, String.to_atom(direction)})
    # broadcast socket, "update_game", %{game: Game.client_view(game)}
    {:reply, {:ok, Game.client_view(game)}, socket}
  end

  @doc """
    delete the tank which has been killed and in the destroyed_tanks_last_frame list
  """
  def handle_in("delete_a_destroyed_tank", %{"uid" => uid}, %{assigns: %{name: name}} = socket) do
    game = GenServer.call(name, :get_state)
    GenServer.cast(name, {:delete_tank, uid})
    broadcast socket, "update_game", %{game: Game.client_view(game)}
    {:reply, {:ok, Game.client_view(game)}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
