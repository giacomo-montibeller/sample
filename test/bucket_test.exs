defmodule BucketTest do
  use ExUnit.Case, async: true

  test "stores values by key" do
    {:ok, bucket} = Sample.Bucket.start_link([])
    assert Sample.Bucket.get(bucket, "milk") == nil

    Sample.Bucket.put(bucket, "milk", 3)
    assert Sample.Bucket.get(bucket, "milk") == 3
  end

end
