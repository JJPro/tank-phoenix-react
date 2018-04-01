defmodule TanksWeb.ChatChannel do
  use TanksWeb, :channel
  alias Tanks.Accounts

  def join("chat:" <> name, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("chat", %{"uid" => uid, "message" => msg} = payload, socket) do
    user = Accounts.get_user!(uid)
    broadcast socket, "chat", %{uid: uid, message: msg, name: user.name}
    {:noreply, socket}
  end

  def handle_in("typing", %{"uid" => uid}, socket) do
    user = Accounts.get_user!(uid)
    broadcast_from! socket, "typing", %{name: user.name}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
