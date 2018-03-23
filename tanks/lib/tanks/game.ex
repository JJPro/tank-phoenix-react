defmodule Tanks.Game do
  @moduledoc """
  manage game state
  """

  def new do
    %{
      tanks: [],
      missiles: [],
      bricks: [],
      steels: [],
    }
  end

  @doc """
  Generates client view of the game state from internal game state,
   later sent to client as json
   game: game %{tanks: list,
                missiles: list,
                bricks: list,
                steels: list,
                destroyed_tanks_last_frame: list of tanks,
                    # the tank struct has player property,
                    # with that we could tell which players to notify about their game over status

               }
  """
  def client_view(game) do

  end

  @doc """
  User operating tank to move in given direction

  - update orientation
  - update coordinates moving in orientation direction for 1 unit
  -
  """
  def move(game, player, direction) do
  end

  @doc """
  Get the next state of the game, absent of player operations

  - detect collisions:  -> handle_collisions(game) => game
    - missile with bricks
      - remove missile
      - remove bricks
    - missile with tanks
      - remove missile
      - decrease tank hp
        - remove tank if hp is 0
    - missile with missile
      - remove both missiles
  - update location of missiles
  """
  def next_state(game) do

  end

  @doc """
  Handle collisions :
  - missile with bricks
    - remove missile
    - remove bricks
  - missile with tanks
    - remove missile
    - decrease tank hp
      - remove tank if hp is 0
  - missile with missile
    - remove both missiles

  """
  defp handle_collisions(game) do
    game.missiles |> Enum.reduce(game, fn (missile, game) ->
      %{tanks: tanks, hit?: tanks_hit?} = handle_collision_tanks(missile, game.tanks)
      %{missiles: missiles, hit?: missiles_hit?} = handle_collision_missiles(missile, game.missiles)
      %{bricks: bricks, hit?: bricks_hit?} = handle_collision_bricks(missile, game.bricks)
      missiles = if tanks_hit? || missiles_hit? || bricks_hit?,
                  do: Enum.filter(missiles, fn m -> m == missile end),
                  else: missiles
      %{game | tanks: tanks,
               missiles: missiles,
               bricks: bricks}
    end)
  end

  @doc """
  :: %{bricks: bricks, hit?: boolean}
  """
  defp handle_collision_bricks(missile, bricks) do
    new_bricks = bricks
    |> Enum.filter(fn brick -> !collide?(missile, brick) end)

    hit? = length(new_bricks) != length(bricks)

    %{bricks: new_bricks, hit?: hit?}
  end
  @doc """
  :: %{tanks: tanks, hit?: boolean}
  """
  defp handle_collision_tanks(missile, tanks) do
    new_tanks = tanks
    |> Enum.filter(fn tank -> !collide?(missile, tank) end)

    hit? = length(new_tanks) != length(tanks)

    %{bricks: new_tanks, hit?: hit?}
  end
  @doc """
  :: %{missiles: tanks, hit?: boolean}
  """
  defp handle_collision_missiles(missile, missiles) do
    # todo: avoid comparing with itself.
    new_missiles = missiles
    |> Enum.filter(fn m -> !collide?(missile, m) || missile.direction != m.direction end)

    hit? = length(new_missiles) != length(missiles)

    %{missiles: new_missiles, hit?: hit?}
  end

  defp collide?(a, b) do
    abs((a.x + a.width/2) - (b.x + b.width/2)) <= (a.width + b.width) / 2 &&
    abs((a.y + a.height/2) - (b.y + b.height/2)) <= (a.height + b.height) / 2
  end
end
