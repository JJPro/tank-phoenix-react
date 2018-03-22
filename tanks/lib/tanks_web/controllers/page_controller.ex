defmodule TanksWeb.PageController do
  use TanksWeb, :controller
  alias Tanks.Game

  def index(conn, _params) do
    render conn, "index.html"
  end

  @doc """
  ajax response funtion
  """
  def get_game_status_with_name(conn, %{"name" => game_name}) do
    statuses = %{full: "full", inbattle: "in battle", open: "open", non_exist: ""}

    game = Tanks.GameBackup.load(game_name)
    # IO.puts ">>>>>>> getting game"
    # IO.inspect game;
    game_status = game && game.status || statuses.non_exist

    render(conn, "show.json", game_status: game_status)

    # sample response for testing
    # render(conn, "show.json", game_status: statuses.full)

  end

end
