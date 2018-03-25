defmodule TanksWeb.PageView do
  use TanksWeb, :view
  alias Tanks.Entertainment

  @doc """
  json response template to ajax querying game status
  """
  def render("show.json", %{room_status: status}) do
    %{data: %{room_status: status}}
  end
end
