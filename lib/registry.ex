defmodule Sample.Registry do
  use GenServer

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(registry, key) do
    GenServer.call(registry, {:lookup, key})
  end

  def create(registry, key) do
    GenServer.cast(registry, {:create, key})
  end

  # Server

  @impl true
  def init(:ok) do
    buckets = %{}
    refs = %{}
    {:ok, {buckets, refs}}
  end

  @impl true
  def handle_call({:lookup, key}, _, state) do
    {buckets, _} = state
    {:reply, Map.fetch(buckets, key), state}
  end

  @impl true
  def handle_cast({:create, key}, {buckets, refs}) do
    if Map.has_key?(buckets, key) do
      {:noreply, {buckets, refs}}
    else
      {:ok, bucket} = Sample.Bucket.start_link([])
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, key)
      buckets = Map.put(buckets, key, bucket)
      {:noreply, {buckets, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _, _}, {buckets, refs}) do
    {key, refs} = Map.pop(refs, ref)
    buckets = Map.delete(buckets, key)
    {:noreply, {buckets, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
