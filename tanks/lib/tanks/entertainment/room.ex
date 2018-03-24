defmodule Tanks.Entertainment.Room do

  def new(name, user) do
    %{
      name: name,
      players: [%{user: user, ready?: false, owner?: true}],
      observers: [],
      game: nil,
    }
  end

  def add_player(room, user) do
    %{room | players: [%{user: user, ready?: false, owner?: false} | room.players]}
  end

  @doc """
  :: {:ok, room} | {:error, nil}
  3 scenarios:
    1. last player: destroy room
    2. owner & other players in the room: shift owner to first player in line
    3. non-owner: delete element
  """
  def remove_player(room, user) do
    player = get_player_from_user(room, user)

    cond do
      length(room.players) == 1 -> {:error, nil} # last player
      player.owner? -> # is owner
        new_players = List.delete(room.players, get_player_from_user(room, user) )
        [first | rest] = new_players
        new_players = [%{first | owner?: true} | rest]
        {:ok, %{room | players: new_players}}
      true -> # not owner
        new_players = List.delete(room.players, get_player_from_user(room, user) )
        {:ok, %{room | players: new_players}}

    end
  end

  def player_ready(room, user) do
    # IO.puts ".>>> player_ready"
    # IO.inspect room
    # IO.inspect user
    %{room | players: Enum.map(
                        room.players,
                        fn p -> (p.user == user && %{p | ready?: true} || p) end)}
  end

  def cancel_ready(room, user) do
    %{room | players: Enum.map(
                        room.players,
                        fn p -> (p.user == user && %{p | ready?: false} || p) end)}
  end

  def add_observer(room, user) do

  end

  def remove_observer(room, user) do

  end

  @doc """
  :: :open | :full | :playing
  """
  def get_status(room) do
    cond do
      is_nil(room.game) -> :playing
      length(room.players) == 4 -> :full
      true -> :open
    end
  end

  @doc """
  get player from user.
  :: %{user: , ready?:, owner?: } | nil
  """
  defp get_player_from_user(room, user) do
    room.players |> Enum.find(fn p -> p.user == user end)
  end
end
