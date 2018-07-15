defmodule TanksWeb.GameChannel do
  use TanksWeb, :channel

  alias Tanks.GameServer
  alias GenServer
  alias Tanks.Entertainment.Game

  def broadcast_state(game, name) do
    TanksWeb.Endpoint.broadcast("game:#{name}", "update_game", %{game: Game.client_view(game)})
  end

  @doc """
  1. retrieve game state from game_server process
  2. send back game state

  :: send back gameview, no broadcast needed
  """
  def join("game:"<>name, payload, socket) do

    # IO.inspect self, label: ">>>>>>>>> PID of game channel"

    if authorized?(payload) do
      # new game process is attached by room_channel
      name = String.to_atom(name)

      # IO.puts ">>>>>>>>>>> trying to join a game"
      if GenServer.whereis(name) do
        game = GenServer.call(name, :get_state)
        {:ok, Game.client_view(game), socket |> assign(:name, name)
                                             |> assign(:game, game)
                                             |> assign(:uid, payload["uid"])}
      else
        {:error, %{reason: "terminated"}}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc """
  1. ask game_server to fire
  2. send state->gameview to client
  """
  def handle_in("fire", _msg, %{assigns: %{name: name}} = socket) do
    # IO.puts ">>>>>>>>>>>>>>>>>>>>>>> FIREING <<<<<<<<<<<<<"
    # IO.inspect %{user: uid}
    uid = socket.assigns.uid
    game = GenServer.call(name, :get_state)
    game = GenServer.call(name, {:fire, uid})
    broadcast socket, "update_game", %{game: Game.client_view(game)}
    {:noreply, socket}
  end

  @doc """
  1. ask game_server to move player
  2. send state->gameview to client
  """
  def handle_in("move", %{"direction" => direction}, %{assigns: %{name: name}} = socket) do
    uid = socket.assigns.uid
    game = GenServer.call(name, :get_state)
    game = GenServer.call(name, {:move, uid, String.to_atom(direction)})
    broadcast socket, "update_game", %{game: Game.client_view(game)}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
