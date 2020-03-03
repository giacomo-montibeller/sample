defmodule Sample.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(Sample.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert Sample.Registry.lookup(registry, "shopping") == :error

    Sample.Registry.create(registry, "shopping")
    assert {:ok, bucket} = Sample.Registry.lookup(registry, "shopping")

    Sample.Bucket.put(bucket, "milk", 1)
    assert Sample.Bucket.get(bucket, "milk") == 1
  end
end
