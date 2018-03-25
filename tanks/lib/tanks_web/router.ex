defmodule TanksWeb.Router do
  use TanksWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TanksWeb.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", TanksWeb do
    pipe_through :browser

    get "/", AuthController, :index
    get "/register", AuthController, :register
    post "/", AuthController, :login
    delete "/", AuthController, :logout
  end

  scope "/", TanksWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
    get "/room/:name", RoomController, :show
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", TanksWeb do
    pipe_through :api
    get "/room_status/:name", PageController, :get_room_status
  end
end
