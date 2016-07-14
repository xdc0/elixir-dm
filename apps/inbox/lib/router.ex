defmodule Router do
  defmacro __using__(_opts) do
    quote do
      def init(options) do
        IO.puts "Listening !"
        options
      end

      def call(conn, _opts) do
        IO.puts "Calling !"
        route(conn.method, conn.path_info, conn)
      end
    end
  end
end