defmodule TanksWeb.ChatChannel do
  @moduledoc """
  Two situations:
  1. Chat history in gaming room
    - room name is "chat:"<>roomname
    - chat history is automatically created if it fails on saving new messages
    - The chat history is deleted on room deletion inside room_channel.ex
  2. Chat history in the lobby
    - Chat history in the lobby is automatically created on saving new messages as well
      and never deleted.
    - lobby chat name is simply "lobby"
  """
  use TanksWeb, :channel
  alias Tanks.Accounts
  alias Tanks.ChatStore
  alias Tanks.RoomStore

  def join(chat_name, payload, socket) do

    # IO.inspect self, label: ">>>>>>>>> PID of chat channel"
    if authorized?(payload) do
      # load message history from chat store
      socket = assign(socket, :chat_room_name, chat_name)
      chat_history = ChatStore.load_all_messages(chat_name)
      {:ok, %{chat_history: chat_history}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("chat", %{"uid" => uid, "message" => msg} = payload, socket) do
    user = Accounts.get_user!(uid)
    broadcast socket, "chat", %{uid: uid, message: msg, name: user.name}
    ChatStore.save_message(socket.assigns.chat_room_name, %{sender_name: user.name, msg_body: msg})
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
