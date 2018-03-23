defmodule Tanks.Tank do
  alias Tanks.Accounts.User
  defstruct x: 0, y: 0, width: 0, height: 0, hp: 0, orientation: :up, player: %User{}
end
