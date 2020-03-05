defmodule BucketTest do
  use ExUnit.Case, async: true

  setup do
    bucket = start_supervised!(Sample.Bucket)
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert Sample.Bucket.get(bucket, "milk") == nil
  end

  test "insert element in bucket", %{bucket: bucket} do
    Sample.Bucket.put(bucket, "milk", 3)
    assert Sample.Bucket.get(bucket, "milk") == 3
  end

  test "remove element from bucket", %{bucket: bucket} do
    Sample.Bucket.put(bucket, "milk", 3)
    Sample.Bucket.remove(bucket, "milk")
    assert Sample.Bucket.get(bucket, "milk") == nil
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(Sample.Bucket, []).restart == :temporary
  end
end
