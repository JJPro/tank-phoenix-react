defmodule TanksWeb.ChatChannel do
  use TanksWeb, :channel
  alias Tanks.Accounts

  def join("chat:" <> name, %{"uid" => uid} = payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chat:lobby).
  def handle_in("shout", %{"uid" => uid, "message" => msg} = payload, socket) do
    user = Accounts.get_user!(uid)
    broadcast socket, "shout_back", %{uid: uid, message: msg, username: user.name}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
