defmodule Tanks.Entertainment.Room do

  alias Tanks.Entertainment.Game
  alias Tanks.GameServer

  def new(name, user) do
    urls = ["/images/tank-cyan.png",
            "/images/tank-red.png",
            "/images/tank-army-green.png",
            "/images/tank-yellow.png",
            "/images/tank-khaki.png",
            "/images/tank-green.png",
            "/images/tank-magenta.png",
            "/images/tank-purple.png",]
    %{
      name: name,
      players: [%{user: user, ready?: false, owner?: true, tank_thumbnail: Enum.random(urls)}],
      playing?: false,
    }
  end

  def add_player(room, user) do
    urls = ["/images/tank-cyan.png",
            "/images/tank-red.png",
            "/images/tank-army-green.png",
            "/images/tank-yellow.png",
            "/images/tank-khaki.png",
            "/images/tank-green.png",
            "/images/tank-magenta.png",
            "/images/tank-purple.png",]
    used_urls = Enum.map(room.players, fn p -> p.tank_thumbnail end)
    available_urls = urls -- used_urls
    thumbnail = Enum.random(available_urls)

    # if user already exists in the room
    if get_player_from_user(room, user) do
      room
    else
      %{room | players: [%{user: user, ready?: false, owner?: false, tank_thumbnail: thumbnail} | room.players]}
    end
  end

  @doc """
  :: {:ok, room} | {:last_player, nil} | {:no_exist, nil}
  3 scenarios:
    1. last player: destroy room, return {:error, nil}
    2. owner & other players in the room: shift owner to first player in line
    3. non-owner: delete element
  """
  def remove_player(room, user) do
    player = get_player_from_user(room, user)

    cond do
      is_nil(player) -> {:no_exist, nil}
      length(room.players) == 1 -> {:last_player, nil} # last player
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
    # IO.puts ">>>> player_ready"
    # IO.inspect user
    # IO.puts "********** Before"
    # IO.inspect room


    room = %{room | players: Enum.map(
                        room.players,
                        fn p -> (p.user == user && %{p | ready?: true} || p) end)}
    # IO.puts "*********** After"
    # IO.inspect room
  end

  def player_cancel_ready(room, user) do
    %{room | players: Enum.map(
                        room.players,
                        fn p -> (p.user == user && %{p | ready?: false} || p) end)}
  end

  @doc """
  :: {:ok, %{room: room}} | {:error, %{reason: string}}
  """
  def start_game(room) do
    cond do
      length(room.players) < 2 ->
        {:error, %{reason: 'not enough players'}}
      Enum.any?(room.players, fn(p) -> not p.ready? end) ->
        {:error, %{reason: 'players are not ready'}}
      true ->
        GameServer.start(Game.new(room.players), room.name)
        {:ok, %{room | playing?: true}}
    end
  end

  def end_game(room) do
    # terminate game process, this is an automatic thing in game server
    # reset ready state
    # reset playing status
    %{room | playing?: false, players: Enum.map(room.players, fn p -> %{p | ready?: false} end)}
  end

  @doc """
  :: :open | :full | :playing
  """
  def get_status(room) do
    cond do
      room.playing? -> :playing
      length(room.players) == 4 -> :full
      true -> :open
    end
  end

  @doc """
  get player from user.
  :: %{user: , ready?:, owner?: } | nil
  """
  def get_player_from_user(room, user) do
    room.players |> Enum.find(fn p -> p.user == user end)
  end
end
