defmodule TanksWeb.PageView do
  use TanksWeb, :view
  alias Tanks.Entertainment

  @doc """
  json response template to ajax querying game status
  """
  def render("show.json", %{game_status: status}) do
    %{data: %{game_status: status}}
  end
end
