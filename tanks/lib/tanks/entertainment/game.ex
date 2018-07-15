defmodule Tanks.Entertainment.Game do
  @moduledoc """
  manage game state
  """

  alias Tanks.Entertainment.Components.{Missile, Tank, Steel, Brick, Map}

  @doc """
  Player is same as in room
  """
  def new(players, width \\ 26, height \\ 26) do
    tanks = case length(players) do
      2 -> [%Tank{x: 0, y: 0, orientation: :down, player: Enum.at(players, 0)},
            %Tank{x: width-2, y: height-2, orientation: :up, player: Enum.at(players, 1)}]
      3 -> [%Tank{x: 0, y: 0, orientation: :down, player: Enum.at(players, 0)},
            %Tank{x: width-2, y: height-2, orientation: :up, player: Enum.at(players, 1)},
            %Tank{x: 0, y: height-2, orientation: :right, player: Enum.at(players, 2)},]
      4 -> [%Tank{x: 0, y: 0, orientation: :down, player: Enum.at(players, 0)},
            %Tank{x: width-2, y: height-2, orientation: :up, player: Enum.at(players, 1)},
            %Tank{x: 0, y: height-2, orientation: :right, player: Enum.at(players, 2)},
            %Tank{x: width-2, y: 0, orientation: :left, player: Enum.at(players, 3)}, ]
    end

    map = pick_a_map();

    tanks = attach_images_to_tanks(tanks);

    %{
      canvas: %{width: width, height: height},
      tanks: tanks,
      missiles: [],
      bricks: map.bricks,
      steels: map.steels,
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
    # IO.inspect {"missiles", game.missiles}
    # format player to json format with player_data(player)
    %{game | tanks: jsonify_tanks(game.tanks),
             destroyed_tanks_last_frame: jsonify_tanks(game.destroyed_tanks_last_frame)}
  end

  @doc """
  User operating tank to move in given direction
  :: game

  - update orientation
  - update coordinates moving in orientation direction for 1 unit
  -
  """
  def move(game, player_id, direction) do
    tanks = Enum.map(game.tanks, fn t ->
      if t.player.user.id == player_id do
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
  def fire(game, player_id) do
    tank = game.tanks |> Enum.find(fn t -> t.player.user.id == player_id end)
    # IO.inspect %{event: "fireing", tank: tank}
    if tank do
      missile = case tank.orientation do
        :up -> %Missile{x: tank.x + tank.width/2, y: tank.y, direction: :up}
        :right -> %Missile{x: tank.x + tank.width, y: tank.y+tank.height/2, direction: :right}
        :down -> %Missile{x: tank.x + tank.width/2, y: tank.y+tank.height, direction: :down}
        :left -> %Missile{x: tank.x, y: tank.y+tank.height/2, direction: :left}
      end
      %{game | missiles: [missile | game.missiles]}
    else
      game
    end
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

  def get_player_from_uid(game, uid) do
    user = Tanks.Accounts.get_user!(uid)
    game.tanks
    |> Enum.map(fn(t) -> t.player end)
    |> Enum.find(fn player -> player.user == user end)

  end

  defp update_location_of_missiles(game) do
    new_missiles = game.missiles
                    |> Enum.map(
                      fn m ->
                        case m.direction do
                          :up -> %{m | y: m.y - m.speed}
                          :down -> %{m | y: m.y + m.speed}
                          :left -> %{m | x: m.x - m.speed}
                          :right -> %{m | x: m.x + m.speed}
                        end
                      end )
                    # remove missiles out of view:
                    |> Enum.filter( fn m -> m.x+m.width >= 0 &&
                                            m.x <= game.canvas.width &&
                                            m.y+m.width >= 0 &&
                                            m.y <= game.canvas.height
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
    game = game.missiles |> Enum.reduce(game, fn (m, game) ->
      cond do
        hit?(m, game.bricks) ->
          # IO.puts ">>>>>>>>>> HIT Brick"

            new_missiles = Enum.reject(game.missiles, fn mm -> mm == m end)
            new_bricks = Enum.reject(game.bricks, fn b -> collide?(b, m) end)
            %{game | missiles: new_missiles, bricks: new_bricks}
        hit?(m, game.steels) ->
          # IO.puts ">>>>>>>>>> HIT Steel"

            new_missiles = Enum.reject(game.missiles, fn mm -> mm == m end)
            %{game | missiles: new_missiles}
        hit_tanks?(m, game.tanks) ->
          # IO.puts ">>>>>>>>>> HIT Tank"
            new_missiles = Enum.reject(game.missiles, fn mm -> mm == m end)
            # decrease tank hp, and delete and add to destroyed_list if new hp = 0
            new_tanks = game.tanks
            |> Enum.map(fn t -> if collide_missile_tank?(m,t), do: %Tank{t | hp: t.hp-1}, else: t end) # decrease tank hp
            |> Enum.reject(fn t -> t.hp == 0 end) # filter out destroyed tanks
            game = %{game | missiles: new_missiles, tanks: new_tanks, destroyed_tanks_last_frame: game.tanks -- new_tanks}

            # IO.puts ">>>>>>>>>>>> HIT TANK"
            # IO.inspect {">>>>>>>>>>>>>>>", length(game.tanks)}
            game

        hit_other_missiles?(m, game.missiles) ->
          # IO.puts ">>>>>>>>>> HIT Other MISSILE"

            new_missiles = Enum.reject(game.missiles, fn mm -> collide?(mm, m) end)
            %{game | missiles: new_missiles}
        true ->
          # IO.puts ">>>>>>>>>> NO HIT"

          game # no collision with this missile detected
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

  defp hit_other_missiles?(missile, missiles) do
    missiles
    |> Enum.reject(fn m -> m == missile end)
    |> Enum.any?(fn m -> collide?(missile, m) end)
  end

  defp hit_tanks?(missile, tanks) do
    Enum.any?(tanks, fn o -> collide_missile_tank?(missile, o) end)
  end
  defp collide_missile_tank?(missile, tank) do
    collide? = missile.x >= tank.x && missile.x <= tank.x + tank.width &&
               missile.y >= tank.y && missile.y <= tank.y + tank.height

    # tank center point {cx, cy}
    {cx, cy} = {tank.x+tank.width/2, tank.y+tank.height/2}
    my_own_missile? = case missile.direction do
      :up -> missile.y < cy
      :down -> cy < missile.y
      :left -> missile.x < cx
      :right -> cx < missile.x
    end
    collide? && !my_own_missile?
  end

  defp collide?(a, b) do
    # abs((a.x + a.width/2) - (b.x + b.width/2)) <= (a.width + b.width) / 2 &&
    # abs((a.y + a.height/2) - (b.y + b.height/2)) <= (a.height + b.height) / 2
    :math.pow((a.x+a.width/2)-(b.x+b.width/2), 2) + :math.pow((a.y+a.height/2)-(b.y+b.height/2), 2) <= :math.pow(a.width+b.width, 2)


  end

  defp can_tank_move?(:up, tank, game) do
    # edges
    edge_block? = tank.y <= 0
    # walls and tanks
    obstacles_block? = Enum.concat([game.bricks, game.steels, game.tanks])
                    |> Enum.any?(fn o ->
                      o.y+o.height == tank.y &&
                      tank.x > o.x-tank.width &&
                      tank.x < o.x+o.width end)
    !edge_block? && !obstacles_block?
  end
  defp can_tank_move?(:down, tank, game) do
    # edges
    edge_block? = tank.y + tank.height >= game.canvas.height
    # walls and tanks
    obstacles_block? = Enum.concat([game.bricks, game.steels, game.tanks])
                    |> Enum.any?(fn o ->
                      tank.y+tank.height == o.y &&
                      tank.x > o.x-tank.width &&
                      tank.x < o.x+o.width end)
    !edge_block? && !obstacles_block?
  end
  defp can_tank_move?(:left, tank, game) do
    # edges
    edge_block? = tank.x <= 0
    # walls and tanks
    obstacles_block? = Enum.concat([game.bricks, game.steels, game.tanks])
                    |> Enum.any?(fn o ->
                      tank.x == o.x + o.width &&
                      tank.y > o.y - tank.height &&
                      tank.y < o.y + o.height end)
    !edge_block? && !obstacles_block?
  end
  defp can_tank_move?(:right, tank, game) do
    # edges
    edge_block? = tank.x + tank.width >= game.canvas.width
    # walls and tanks
    obstacles_block? = Enum.concat([game.bricks, game.steels, game.tanks])
                    |> Enum.any?(fn o ->
                      tank.x + tank.width == o.x &&
                      tank.y > o.y - tank.height &&
                      tank.y < o.y + o.height end)
    !edge_block? && !obstacles_block?
  end

  @doc """
  format player object to json format
  player is: %{owner?: bool, ready?: bool, user: %User{}}
  :: %{name: string, id: int, owner?: bool, ready?: bool}
  """
  defp player_data(player) do
    %{
      name: player.user.name,
      id: player.user.id,
      is_owner: player.owner?,
      is_ready: player.ready?,
      tank_thumbnail: player.tank_thumbnail,
    }
  end

  defp jsonify_tanks(tanks) do
    Enum.map(tanks, fn t -> %Tank{t | player: player_data(t.player)} end)
  end

  defp attach_images_to_tanks(tanks) do
    tanks
    |> Enum.map(fn(t) -> %{t | image: t.player.tank_thumbnail} end)
  end


  @doc """
  Randomly pick a map from predefined s et of maps
  :: %{
        bricks: list of %Brick{x: xx, y: yy},
        steels: list of %Steel{x: xx, y: yy}
     }
  """
  defp pick_a_map do
    {:ok, map} = Map.random_a_game_map()
    %{map | bricks: Enum.map(map.bricks, fn b -> %Brick{x: b.x, y: b.y} end),
            steels: Enum.map(map.steels, fn s -> %Steel{x: s.x, y: s.y} end)}
  end

  @doc """
  """
  def remove_destroyed_tank(game, uid) do
    new_tank_list = Enum.filter(game.destroyed_tanks_last_frame, fn(x) ->
      x.player.id != uid
    end)

    %{game | destroyed_tanks_last_frame: new_tank_list}
  end
end
