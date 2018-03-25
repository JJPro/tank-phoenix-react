defmodule Tanks.RoomStore do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(name, room) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, room)
    end
  end

  def load(name) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name)
    end
  end

  def delete(name) do
    Agent.update __MODULE__, fn state ->
      Map.delete(state, name)
    end
  end

  @doc """
  list all room.
  :: [%{name: , room: }]
  """
  def list do
    Agent.get __MODULE__, fn state ->
      state
      |> Enum.map(fn {name, room} -> %{name: name, room: room} end)
    end
  end
end
