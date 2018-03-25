defmodule TanksWeb.RoomController do
  use TanksWeb, :controller
  alias Tanks.Entertainment.{Room, Game}


  def show(conn, %{"name" => name}) do
    IO.puts ">>>>>> showing room"
    IO.inspect name
    render conn, "show.html", name: name
  end

end
