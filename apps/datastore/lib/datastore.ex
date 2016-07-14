defmodule DataStore do
  use Application

  alias DataStore.Messages

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(DataStore.Worker, [arg1, arg2, arg3]),
      worker(Messages, []),
      supervisor(Task.Supervisor, [[name: DataStore.DistSupervisor]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DataStore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
