defmodule TanksWeb.GameChannel do
  use TanksWeb, :channel

  @doc """
  1. retrieve/spawn up a game_tick process, and save the pid to room
  2. assign game pid to socket for faster access, so don't have to ask roomstore again and again for each socket receive call
  3. send back game state

  :: send back gameview, no broadcast needed
  """
  def join("game:"<>name, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc """
  get current game state from game_tick process and send back to client:
    1. get state from game_tick
    2. send state->gameview to client
  """
  def handle_in("request_state", payload, socket) do

  end

  @doc """
  1. ask game_tick to fire
  2. send state->gameview to client
  """
  def handle_in("fire", payload, socket) do

  end

  @doc """
  1. ask game_tick to move player
  2. send state->gameview to client
  """
  def handle_in("move", payload, socket) do

  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
