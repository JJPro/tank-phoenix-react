defmodule TanksWeb.PageController do
  use TanksWeb, :controller
  alias Tanks.Entertainment.{Room, Game}

  def index(conn, _params) do
    render conn, "index.html"
  end

  @doc """
  ajax response funtion
  """
  def get_room_status(conn, %{"name" => name}) do
    room = Tanks.RoomStore.load(name)
    # IO.puts ">>>>>>> getting game"
    # IO.inspect game;
    room_status = if room, do: Room.get_status(room), else: nil

    render(conn, "show.json", room_status: room_status)
  end

end
