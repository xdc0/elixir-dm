defmodule Inbox.Messages do
  use Router

  def route("GET", ["messages", recipient], conn) do
    # messages = DataStore.Messages.all(email)
    IO.puts "Attempting to retrieve messages for: " <> recipient
    messages = Task.Supervisor.async({DataStore.DistSupervisor, :datastore@felurian},
      DataStore.Messages, :all, [recipient]) |>
      Task.await

    case messages do
      nil ->
        messages = []
      _ ->
    end

    IO.inspect messages

    contents = EEx.eval_file("templates/messages.eex", [messages: messages])
    conn |>
      Plug.Conn.put_resp_content_type("text/html") |>
      Plug.Conn.send_resp(200, contents)
  end

  def route("POST", ["messages", sender], conn) do
    { :ok, body, _ } = Plug.Conn.read_body(conn, [])
    # The above return an uri encoded string, the following is a super naive manual parser.

    IO.inspect body

    body = String.split(body, "&", []) |>
      Enum.map(fn(x) -> String.split(x, "=", []) end) |>
      List.foldl(%{}, fn(x, acc) -> Map.put(acc, hd(x), List.last(x) |> URI.decode) end)

    task = Task.Supervisor.async({Messages.DistSupervisor, :sender@felurian},
      Messages.Send, :dispatch, [sender, body])
    contents = EEx.eval_file("templates/sent.eex")

    conn |> Plug.Conn.send_resp(200, contents)
  end

  def route(_method, _path, conn) do
    conn |> Plug.Conn.send_resp(404, "Not found")
  end
end
