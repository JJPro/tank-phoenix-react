defmodule Tanks.GameServer do
  alias Tanks.Entertainment.Game


## Interfaces
  @doc """
  spawn up a process to manage game state
  :: pid
  """
  def start(game, name) do
    # state is {name:, game: }
    # we use room name as our GenServer server name
    GenServer.start(__MODULE__, {name, game}, name: name)
    GenServer.cast(name, :auto_update_state)
  end



## Server Implementations
  def handle_cast(:auto_update_state, {servername, game}) do
    Process.sleep(50) # 50 * 20 = 1000 => 20 FPS
    GenServer.cast(servername, :auto_update_state)
    {:noreply, {servername, Game.next_state(game)}}
  end

  def handle_cast(:request_state, {servername, game}) do

  end

  def handle_cast({:fire, player}, {servername, game}) do

  end

  def handle_cast({:move, player, direction}, {servername, game}) do

  end

end
