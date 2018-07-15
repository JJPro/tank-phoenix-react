defmodule TanksWeb.ListRoomsChannel do
  @moduledoc """
  Channel for Listing Gaming Rooms

  join -> collect and send all game statuses
  """
  use TanksWeb, :channel
  alias Tanks.Entertainment.Room
  alias Tanks.Accounts

  @doc """
  :: {:ok, %{rooms: list}}
  """
  def join("list_rooms", payload, socket) do
    # IO.puts ">>>>>>> joining list rooms"
    if authorized?(payload) do
      # collect all rooms
      # get status of all rooms
      # return %{name: , status: }

      # IO.inspect Tanks.RoomStore.list
      rooms =
        Tanks.RoomStore.list # get all rooms [%{name:, room:}]
        |> Enum.map(fn %{name: name, room: room} ->
          %{name: name, status: Room.get_status(room)} end)
      # IO.inspect rooms
      #### Users online ####
      # return immediately if user is not logged in
      # get user name
      # insert it into a ETS table
      # broadcast to all clients to update the online user list
      # then read the ets table and send the user list back to client

      if uid = payload["uid"] do

        user = Accounts.get_user!(uid) # get the user

        # insert current user info into ets table, table is created upon application startup in application.ex
        :ets.insert(:users_online, {uid, user.name})
        # WARNING broadcast won't work until joining is finished, so we send a message to ourself for handling the broadcasting later.
        send(self(), :after_join)

        # assign uid in socket
        socket = assign(socket, :uid, uid)

        # IO.inspect(socket.assigns, label: ">>>>>>>>> socket assign")
      end

      {:ok, %{rooms: rooms}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    broadcast_update_users_online(socket)
    {:noreply, socket}
  end

  @doc """
  update users online indicator

  Do the following:
  1. check if the user is logged in, do the following if is logged in:
    a. remove current user from the ets table
    b. broadcast to all clients to update the users online list
  """
  def terminate(_msg, socket) do
    # IO.inspect(socket.assigns, label: ">>>>>>> terminating socket asisgns: ")

    if Map.has_key?(socket.assigns, :uid) do # Step 1.
      uid = socket.assigns.uid
      # 1.a. remove current user from the ets table
      :ets.delete(:users_online, uid)
      # 1.b. broadcast to all clients to update ther users online list
      broadcast_update_users_online(socket)
    end

    {:shutdown, :closed}
  end
  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp broadcast_update_users_online(socket) do
    users_online = :ets.tab2list(:users_online)
    broadcast!(socket, "update_users_online", %{users_online: Enum.into(users_online, [], fn {k,v} -> %{id: k, name: v} end)})
  end
end
