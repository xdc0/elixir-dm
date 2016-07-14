defmodule DataStore.Messages do
  def start_link do
    :ets.new(:messages, [:named_table, read_concurrency: true])
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    :ets.insert(:messages, {:pid, pid })
    {:ok, pid}
  end

  def all(recipient) do
    {:ok, repository} = get_repository
    IO.puts "Retrieving all messages for " <> recipient
    messages = Agent.get(repository, fn map -> Map.get(map, recipient) end)

    IO.inspect messages

    messages
  end

  def put(recipient, message) do
    {:ok, repository} = get_repository

    IO.puts "Received new message for " <> recipient
    Agent.update(repository, fn map ->
      messages = Map.get(map, recipient)
      case messages do
        nil ->
          Map.put(map, recipient, [message])
        _ ->
          Map.put(map, recipient, messages ++ [message])
      end
    end)
  end

  def get_repository do
    case :ets.lookup(:messages, :pid) do
      [{ _, pid }] -> { :ok, pid }
      [] -> :error
    end
  end
end