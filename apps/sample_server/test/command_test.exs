defmodule SampleServer.CommandTest do
  use ExUnit.Case, async: true
  doctest SampleServer.Command
  setup context do
    registryName = context.test
    registry = start_supervised!({Sample.Registry, name: registryName})
    %{registry: registryName}
  end
  test "sample test to inject collaborator", %{registry: registryName} do
    Sample.Registry.start_link(name: registryName)
    SampleServer.Command.run({:create, "bucket"}, registryName)
    SampleServer.Command.run({:put, "bucket", "key", "value"}, registryName)
    {:ok, value} = SampleServer.Command.run({:get, "bucket", "key"}, registryName)
    assert value == "value\r\nOK\r\n"
  end
end
