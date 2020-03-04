defmodule Sample.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    start_supervised!({Sample.Registry, name: context.test})
    %{registry: context.test}
  end

  test "retrieves an error if bucket does not exists", %{registry: registry} do
    assert Sample.Registry.lookup(registry, "shopping") == :error
  end

  test "spawns buckets", %{registry: registry} do
    Sample.Registry.create(registry, "shopping")
    assert {:ok, bucket} = Sample.Registry.lookup(registry, "shopping")

    Sample.Bucket.put(bucket, "milk", 1)
    assert Sample.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    Sample.Registry.create(registry, "shopping")
    {:ok, bucket} = Sample.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)

    # make a sync call to wait the DOWN message
    Sample.Registry.create(registry, "bogus")

    assert Sample.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Sample.Registry.create(registry, "shopping")
    {:ok, bucket} = Sample.Registry.lookup(registry, "shopping")

    Agent.stop(bucket, :shutdown)

    # make a sync call to wait the DOWN message
    Sample.Registry.create(registry, "bogus")

    assert Sample.Registry.lookup(registry, "shopping") == :error
  end
end
