defmodule Sample.Registry do
  use GenServer

  # Client

  def start_link(opts) do
    registry = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, registry, opts)
  end

  def lookup(registry, key) do
    case :ets.lookup(registry, key) do
      [{^key, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  def create(registry, key) do
    GenServer.call(registry, {:create, key})
  end

  # Server

  @impl true
  def init(table) do
    buckets = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {buckets, refs}}
  end

  @impl true
  def handle_call({:create, key}, _from, {buckets, refs}) do
    case lookup(buckets, key) do
      {:ok, pid} ->
        {:reply, pid, {buckets, refs}}
      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(Sample.BucketSupervisor, Sample.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, key)
        :ets.insert(buckets, {key, pid})
        {:reply, pid, {buckets, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _, _}, {buckets, refs}) do
    {key, refs} = Map.pop(refs, ref)
    :ets.delete(buckets, key)
    {:noreply, {buckets, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
