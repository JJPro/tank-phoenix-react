defmodule Tanks.ChatStore do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  The store is limited to save the most recent 100 chat messages,
  automatically deletes the earliest message when exceeding the limit.
  """
  @spec save_message(string(), Map.t()) :: nil
  def save_message(room, %{sender_name: name, msg_body: body} = msg) do
    Agent.update __MODULE__, fn state ->
      # IO.inspect(state, label: ">>>>>>>>> chat agent state")
      Map.update(state, room, [msg], fn messages ->
        # IO.inspect(messages, label: ">>>>>>>> chat store for room: #{room}")
        if length(messages) >= 100 do
          messages = List.delete_at(messages, 99)
        end
        [msg|messages]
      end)
    end
  end

  def load_all_messages(room) do
    chat_history = Agent.get __MODULE__, fn state ->
      Map.get(state, room)
    end

    if chat_history, do: chat_history |> Enum.reverse, else: []
  end

  def delete_chat(room) do
    Agent.update __MODULE__, fn state ->
      Map.delete(state, room)
    end
  end

end
