defmodule SampleServer.Command do
  @doc ~S"""
    Parses the given `line` into a command.

    ## Examples

        iex> SampleServer.Command.parse "CREATE shopping\r\n"
        {:ok, {:create, "shopping"}}

        iex> SampleServer.Command.parse "CREATE  shopping  \r\n"
        {:ok, {:create, "shopping"}}

        iex> SampleServer.Command.parse "PUT shopping milk 1\r\n"
        {:ok, {:put, "shopping", "milk", "1"}}

        iex> SampleServer.Command.parse "GET shopping milk\r\n"
        {:ok, {:get, "shopping", "milk"}}

        iex> SampleServer.Command.parse "DELETE shopping eggs\r\n"
        {:ok, {:delete, "shopping", "eggs"}}

    Unknown commands or commands with the wrong number of
    arguments return an error:

        iex> SampleServer.Command.parse "UNKNOWN shopping eggs\r\n"
        {:error, :unknown_command}

        iex> SampleServer.Command.parse "GET shopping\r\n"
        {:error, :unknown_command}
  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      _ -> {:error, :unknown_command}
    end
  end

  def run({:create, bucket}, registry) do
    Sample.Registry.create(registry, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket, key}, registry) do
    lookup(bucket, registry, fn pid ->
      value = Sample.Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end)
  end

  def run({:put, bucket, key, value}, registry) do
    lookup(bucket, registry, fn pid ->
      Sample.Bucket.put(pid, key, value)
      {:ok, "OK\r\n"}
    end)
  end

  def run({:delete, bucket, key}, registry) do
    lookup(bucket, registry, fn pid ->
      Sample.Bucket.remove(pid, key)
      {:ok, "OK\r\n"}
    end)
  end

  defp lookup(bucket, registry, callback) do
    case Sample.Registry.lookup(registry, bucket) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
