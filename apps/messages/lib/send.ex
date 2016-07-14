defmodule Messages.Send do
  def dispatch(sender, document) when is_map(document) do
    IO.puts "Starting sending message from: " <> sender
    IO.inspect document

    :timer.sleep(1500)

    recipient = document["recipient"]
    document = %{
      sender: sender,
      subject: document["subject"],
      message: document["message"],
      timestamp: :os.system_time(:seconds)
    }

    IO.inspect document
    IO.puts "Done!"

    Task.Supervisor.async({DataStore.DistSupervisor, :datastore@felurian },
      DataStore.Messages, :put, [recipient, document]) |>
    Task.await
  end
end
