defmodule SampleServer.Application do
  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: Sample.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> SampleServer.accept(port) end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: SampleServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
