defmodule Sample do
  use Application

  @impl true
  def start(_type, _args) do
    Sample.Supervisor.start_link(name: Sample.Supervisor)
  end
end
