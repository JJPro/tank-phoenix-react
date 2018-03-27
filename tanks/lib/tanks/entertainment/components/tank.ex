defmodule Tanks.Entertainment.Components.Tank do
  alias Tanks.Accounts.User
  defstruct x: 0, y: 0, width: 2, height: 2, hp: 4, orientation: nil, player: nil, image: ""
end
