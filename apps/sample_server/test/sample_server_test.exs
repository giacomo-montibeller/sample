defmodule SampleServerTest do
  use ExUnit.Case
  doctest SampleServer

  test "greets the world" do
    assert SampleServer.hello() == :world
  end
end
