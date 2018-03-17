defmodule TanksWeb.PageController do
  use TanksWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
