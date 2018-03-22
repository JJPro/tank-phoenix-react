defmodule TanksWeb.AuthController do
    use TanksWeb, :controller
    alias Tanks.{Accounts, Accounts.User}

    @doc """
    login page
    """
    def index(%{req_headers: req_headers} = conn, _params) do
      {"referer", url} = req_headers |> Enum.find(fn {k,_v} -> k == "referer" end) || {"referer", nil}
      if !conn.assigns.current_user do
        # render login form
        render conn, "loginform.html", referer: url
      else
        # direct access while logged in
        redirect(conn, to: user_path(conn, :show, conn.assigns.current_user))
      end
    end

    @doc """
    login post action
    """
    def login(conn, %{"email" => email} = _params) do
      # check user existence
      case Accounts.get_user_by_email(email) do
        nil ->
          conn
          |> put_flash(:error, "your email was not found, please try again or register a new account")
          |> redirect(to: auth_path(conn, :index))
        user ->
            conn
            |> put_flash(:info, "Welcome back!")
            |> put_session(:user_id, user.id)
            |> redirect(to: page_path(conn, :index))
      end
    end

    def logout(conn, _params) do
      conn
      |> configure_session(drop: true)
      |> redirect(to: page_path(conn, :index))
    end

    def register(conn, params) do
      referer = params["referer"]
      # {"referer", url} = req_headers |> Enum.find(fn {k,v} -> k == "referer" end)
      changeset = Accounts.change_user(%User{})
      render conn, "register.html", changeset: changeset, referer: referer
    end

end
