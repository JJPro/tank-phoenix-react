defmodule Tanks.Game do
  @moduledoc """
  manage game state
  """

  alias Tanks.{Missile, Tank, Steel, Brick}
  def new do
    %{
      canvas: %{x: 0, y: 0},
      tanks: [],
      missiles: [],
      bricks: [],
      steels: [],
      destroyed_tanks_last_frame: [],
    }
  end

  @doc """
  Generates client view of given game state
   later sent to client as json
   :: %{tanks: list,
        missiles: list,
        bricks: list,
        steels: list,
        destroyed_tanks_last_frame: list of tanks,
            # the tank struct has player property,
            # with that we could tell which players to notify about their game over status

       }
  """
  def client_view(game) do
    game
  end

  @doc """
  User operating tank to move in given direction
  :: game

  - update orientation
  - update coordinates moving in orientation direction for 1 unit
  -
  """
  def move(game, player, direction) do
    tanks = Enum.map(game.tanks, fn t ->
      if t.player == player do
        case direction do
          :up -> %Tank{t | orientation: direction, y: (if can_tank_move?(:up, t, game), do: t.y-1, else: t.y)}
          :down -> %Tank{t | orientation: direction, y: (if can_tank_move?(:down, t, game), do: t.y+1, else: t.y)}
          :left -> %Tank{t | orientation: direction, x: (if can_tank_move?(:left, t, game), do: t.x-1, else: t.x)}
          :right -> %Tank{t | orientation: direction, x: (if can_tank_move?(:right, t, game), do: t.x+1, else: t.x)}
        end
      else
        t
      end
    end)

    %{game | tanks: tanks}

  end

  @doc """
  player fire shots
  :: game

  player tank emits an missile:
    add missile to missiles
      - x, y
      - direction: tank.orientation
      [missile | game.missiles]
  """
  def fire(game, player) do
    tank = game.tanks |> Enum.find(fn t -> t.player == player end)
    missile = case tank.orientation do
      :up -> %Missile{x: tank.x + tank.width/2, y: tank.y, direction: :up}
      :right -> %Missile{x: tank.x + tank.width, y: tank.y+tank.height/2, direction: :right}
      :down -> %Missile{x: tank.x + tank.width/2, y: tank.y+tank.height, direction: :down}
      :left -> %Missile{x: tank.x, y: tank.y+tank.height/2, direction: :left}
    end
    %{game | missiles: [missile | game.missiles]}
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
    game
    |> handle_collisions
    |> update_location_of_missiles
  end

  defp update_location_of_missiles(game) do
    new_missiles = game.missiles
                    |> Enum.map(
                      fn m ->
                        case m.direction do
                          :up -> %{m: m.y - m.speed}
                          :down -> %{m: m.y + m.speed}
                          :left -> %{m: m.x - m.speed}
                          :right -> %{m: m.x + m.speed}
                        end
                      end )
                    # remove missiles out of view:
                    |> Enum.filter( fn m -> m.x+m.width >= 0
                                            && m.x <= game.canvas.width
                                            && m.y+m.width >= 0
                                            && m.y <= game.canvas.height
                                    end )
    %{game | missiles: new_missiles}
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
      - add to game.destroyed_tanks_last_frame
  - missile with missile
    - remove both missiles

  """
  defp handle_collisions(game) do
    game.missiles |> Enum.reduce(game, fn (m, game) ->
      cond do
        hit?(m, game.bricks) ->
          new_missiles = Enum.reject(game.missiles, fn mm -> mm == m end)
          new_bricks = Enum.reject(game.bricks, fn b -> collide?(b, m) end)

          %{game | missiles: new_missiles, bricks: new_bricks}

        hit?(m, game.tanks) ->
          new_missiles = Enum.reject(game.missiles, fn mm -> mm == m end)
          # decrease tank hp, and delete and add to destroyed_list if new hp = 0
          new_tanks = game.tanks
          |> Enum.map(fn t ->
            if collide?(t,m) do
              if t.hp > 1 do  # decrease tank hp
                %Tank{t | hp: t.hp-1}
              else  # mark for delete via nil; add to destroyed list
                game = %{game | destroyed_tanks_last_frame: [t | game.destroyed_tanks_last_frame]}
                nil
              end
            else
              t
            end
           end)
          |> Enum.reject(fn t -> is_nil(t) end)
          %{game | missiles: new_missiles, tanks: new_tanks}

        hit?(m, game.missiles) ->
          new_missiles = Enum.reject(game.missiles, fn mm -> collide?(mm, m) end)

          %{game | missiles: new_missiles}


        true -> game # no collision with this missile detected
      end


    end)
  end

  @doc """
  Did missile hit any of the given obstacles?
  :: boolean
  """
  defp hit?(missile, obstacles) do
    Enum.any?(obstacles, fn o -> collide?(missile, o) end)
  end

  defp collide?(a, b) do
    abs((a.x + a.width/2) - (b.x + b.width/2)) <= (a.width + b.width) / 2 &&
    abs((a.y + a.height/2) - (b.y + b.height/2)) <= (a.height + b.height) / 2
  end

  defp can_tank_move?(:up, tank, game) do
    # edges
    edge_block? = tank.y <= 0
    # walls and tanks
    obstacles_block? = Enum.concat([game.bricks, game.steels, game.tanks])
                    |> Enum.any?(fn o ->
                      o.y+o.height == tank.y
                      && tank.x > o.x-tank.width
                      && tank.x < o.x+o.width end)
    !edge_block? && !obstacles_block?
  end
  defp can_tank_move?(:down, tank, game) do
    # edges
    edge_block? = tank.y + tank.height >= game.canvas.height
    # walls and tanks
    obstacles_block? = Enum.concat([game.bricks, game.steels, game.tanks])
                    |> Enum.any?(fn o ->
                      tank.y+tank.height == o.y
                      && tank.x > o.x-tank.width
                      && tank.x < o.x+o.width end)
    !edge_block? && !obstacles_block?
  end
  defp can_tank_move?(:left, tank, game) do
    # edges
    edge_block? = tank.x <= 0
    # walls and tanks
    obstacles_block? = Enum.concat([game.bricks, game.steels, game.tanks])
                    |> Enum.any?(fn o ->
                      tank.x == o.x + o.width
                      && tank.y > o.y - tank.height
                      && tank.y < o.y + o.height end)
    !edge_block? && !obstacles_block?
  end
  defp can_tank_move?(:right, tank, game) do
    # edges
    edge_block? = tank.x + tank.width >= game.canvas.width
    # walls and tanks
    obstacles_block? = Enum.concat([game.bricks, game.steels, game.tanks])
                    |> Enum.any?(fn o ->
                      tank.x + tank.width == o.x
                      && tank.y > o.y + tank.height
                      && tank.y < o.y end)
    !edge_block? && !obstacles_block?
  end
end
