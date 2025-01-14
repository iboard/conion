defmodule BucketTest do
  use ExUnit.Case
  alias CentralScrutinizer.Store.Server

  test "a bucket is dirty when modified" do
    {:ok, _pid} = Server.new_bucket(:test)
    refute Server.dirty?(:test)
  end

  test "a bucket is not dirty when persisted" do
    {:ok, _pid} = Server.new_bucket(:test)
    {:ok, _} = Server.insert_new(:test, %{some: :thing})
    assert Server.dirty?(:test)
    Server.persist(:test)
    refute Server.dirty?(:test)
  end

  test "start bucket with persistor" do
    {:ok, _pid} = Server.new_bucket(:test, Persistor.File, filename: "data/test/testfile.data")
    Server.persist(:test)
    refute Server.dirty?(:test)
  end

  test "bucket knows it's persistor" do
    {:ok, _pid} =
      Server.new_bucket(:file_test, Persistor.File, filename: "data/test/testfile.data")

    assert {Persistor.File, filename: "data/test/testfile.data"} == Server.persistor(:file_test)
  end
end
