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
    name = String.to_atom(name)
    GenServer.start_link(__MODULE__, {name, game}, name: name)
    GenServer.cast(name, :auto_update_state)
  end

  def init({name, game}) do
    {:ok, {name, game}}
  end

  def terminate(name) do
    GenServer.stop(name)
  end

  # def call(name, message) do
  #   GenServer.call()
  # end



## Server Implementations
  def handle_cast(:auto_update_state, {servername, game}) do
    # IO.puts "@@@@@@@@@@@@@@@ auto_update_state called"
    Process.sleep(50) # 50 * 20 = 1000 => 20 FPS
    GenServer.cast(servername, :auto_update_state)
    {:noreply, {servername, Game.next_state(game)}}
  end

  @doc """
  :: game
  """
  # def handle_call(:get_state, _from, {servername, game}) do
  #   IO.puts ">>>>>>>>>>>>> handle_call :get_state"
  #   IO.inspect
  #   {:reply, game, game}
  # end
  def handle_call(:get_state, _from, {servername, game} = state) do
    # IO.puts ">>>>>>>>>>>>> handle_call :get_state"
    # IO.inspect %{state: state}
    {:reply, game, state}
  end

  def handle_cast({:fire, player}, {servername, game}) do
    {:noreply, {servername, Game.fire(game, player)}}
  end

  def handle_cast({:move, player, direction}, {servername, game}) do
    {:noreply, {servername, Game.move(game, player, direction)}}
  end
end
