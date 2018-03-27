defmodule TanksWeb.RoomController do
  use TanksWeb, :controller
  alias Tanks.Entertainment.{Room, Game}

  plug TanksWeb.Plugs.RequireAuth


  def show(conn, %{"name" => name}) do
    render conn, "show.html", name: name
  end

end
