defmodule Sample.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Sample.BucketSupervisor, strategy: :one_for_one},
      {Sample.Registry, name: Sample.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
