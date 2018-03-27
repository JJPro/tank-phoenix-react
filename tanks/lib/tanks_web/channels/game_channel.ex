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
      game = GenServer.call(name, :get_state)

      {:ok, Game.client_view(game), socket}
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
    {:reply, {:ok, Game.client_view(game)}, socket}
  end

  @doc """
  1. ask game_server to fire
  2. send state->gameview to client
  """
  def handle_in("fire", %{"uid" => uid}, %{assigns: %{name: name}} = socket) do
    player = Game.get_player_from_uid(uid)
    GenServer.cast(name, {:fire, player})
    game = GenServer.call(name, :get_state)
    {:reply, {:ok, Game.client_view(game)}, socket}
  end

  @doc """
  1. ask game_server to move player
  2. send state->gameview to client
  """
  def handle_in("move", %{"uid" => uid, "direction" => direction}, %{assigns: %{name: name}} = socket) do
    player = Game.get_player_from_uid(uid)
    GenServer.cast(name, {:move, player, String.to_atom(direction)})
    game = GenServer.call(name, :get_state)
    {:reply, {:ok, Game.client_view(game)}, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
