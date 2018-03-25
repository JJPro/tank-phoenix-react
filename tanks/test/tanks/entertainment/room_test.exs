defmodule Tanks.RoomTest do
  use Tanks.DataCase

  alias Tanks.Entertainment.Room


  test "add_player" do
    user1 = %{name: "Jason", id: 1}
    user2 = %{name: "Lu", id: 2}
    user3 = %{name: "JI", id: 3}

    room1 = %{
      name: "room1",
      players: [%{user: user1, ready?: false, owner?: true}],
      game: nil,
    }

    room2 = %{ # added user2
      name: "room1",
      players: [%{user: user2, ready?: false, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }

    assert Room.add_player(room1, user2) == room2
  end

  test "remove_player" do
    user1 = %{name: "Jason", id: 1}
    user2 = %{name: "Lu", id: 2}
    user3 = %{name: "JI", id: 3}

    room1 = %{
      name: "room1",
      players: [%{user: user1, ready?: false, owner?: true}],
      game: nil,
    }

    room2 = %{ # added user2
      name: "room1",
      players: [%{user: user2, ready?: false, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }

    room3 = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user2, ready?: false, owner?: true}],
      game: nil,
    }

    room4 = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user3, ready?: false, owner?: false},
                %{user: user2, ready?: false, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }

    #remove standard user
    assert Room.remove_player(room2, user2) == {:ok, room1}
    #remove owner, the other player becomes owner
    assert Room.remove_player(room2, user1) == {:ok, room3}
    #last remove, destroy room
    assert Room.remove_player(room1, user1) == {:error, nil}
    assert Room.remove_player(room3, user2) == {:error, nil}
    assert Room.remove_player(room4, user3) == {:ok, room2}

  end

  test "player_ready" do
    user1 = %{name: "Jason", id: 1}
    user2 = %{name: "Lu", id: 2}
    user3 = %{name: "JI", id: 3}

    room2 = %{ # added user2
      name: "room1",
      players: [%{user: user2, ready?: false, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }
    room2_u1_ready = %{ # added user2
      name: "room1",
      players: [%{user: user2, ready?: false, owner?: false},
                %{user: user1, ready?: true, owner?: true}],
      game: nil,
    }
    room2_u2_ready = %{ # added user2
      name: "room1",
      players: [%{user: user2, ready?: true, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }

    room3 = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user2, ready?: false, owner?: true}],
      game: nil,
    }
    room3_ready = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user2, ready?: true, owner?: true}],
      game: nil,
    }

    room4 = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user3, ready?: false, owner?: false},
                %{user: user2, ready?: false, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }
    room4_u2_ready = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user3, ready?: false, owner?: false},
                %{user: user2, ready?: true, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }

    assert Room.player_ready(room2, user1) == room2_u1_ready
    assert Room.player_ready(room2, user2) == room2_u2_ready
    assert Room.player_ready(room3, user2) == room3_ready
    assert Room.player_ready(room4, user2) == room4_u2_ready
  end

  test "player_cancel_ready" do
    user1 = %{name: "Jason", id: 1}
    user2 = %{name: "Lu", id: 2}
    user3 = %{name: "JI", id: 3}

    room2 = %{ # added user2
      name: "room1",
      players: [%{user: user2, ready?: false, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }
    room2_u1_ready = %{ # added user2
      name: "room1",
      players: [%{user: user2, ready?: false, owner?: false},
                %{user: user1, ready?: true, owner?: true}],
      game: nil,
    }
    room2_u2_ready = %{ # added user2
      name: "room1",
      players: [%{user: user2, ready?: true, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }

    room3 = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user2, ready?: false, owner?: true}],
      game: nil,
    }
    room3_ready = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user2, ready?: true, owner?: true}],
      game: nil,
    }

    room4 = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user3, ready?: false, owner?: false},
                %{user: user2, ready?: false, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }
    room4_u2_ready = %{ # user2 becomes owner
      name: "room1",
      players: [%{user: user3, ready?: false, owner?: false},
                %{user: user2, ready?: true, owner?: false},
                %{user: user1, ready?: false, owner?: true}],
      game: nil,
    }

    assert Room.player_cancel_ready(room2_u1_ready, user1) == room2
    assert Room.player_cancel_ready(room2_u2_ready, user2) == room2
    assert Room.player_cancel_ready(room3_ready, user2) == room3
    assert Room.player_cancel_ready(room4_u2_ready, user2) == room4
  end
end
