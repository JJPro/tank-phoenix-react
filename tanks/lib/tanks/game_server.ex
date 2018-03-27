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

  def terminate(name) do
    GenServer.stop(name)
  end



## Server Implementations
  def handle_cast(:auto_update_state, {servername, game}) do
    Process.sleep(50) # 50 * 20 = 1000 => 20 FPS
    GenServer.cast(servername, :auto_update_state)
    {:noreply, {servername, Game.next_state(game)}}
  end

  @doc """
  :: game
  """
  def handle_call(:get_state, {servername, game}) do
    {:reply, game, game}
  end

  def handle_cast({:fire, player}, {servername, game}) do
    {:noreply, {servername, Game.fire(game, player)}}
  end

  def handle_cast({:move, player, direction}, {servername, game}) do
    {:noreply, {servername, Game.move(game, player, direction)}}
  end
end
