defmodule Tanks.Entertainment.Components.Tank do
  alias __MODULE__
  @enforce_keys [:orientation, :player]
  # alias Tanks.Accounts.User
  defstruct x: 0, y: 0, width: 2, height: 2, hp: 4, orientation: nil, player: nil, image: ""

  def new do
    %Tank{orientation: :down, player: nil}
  end
end
