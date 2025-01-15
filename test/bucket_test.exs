defmodule BucketTest do
  use ExUnit.Case
  alias CentralScrutinizer.Store.Server
  alias CentralScrutinizer.Store.Persistor

  describe "without persistor" do
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
  end

  describe "with file persistor" do
    setup _ do
      filename = "data/test/testfile.data"

      on_exit(fn ->
        File.rm(filename)
      end)

      {:ok, %{filename: filename}}
    end

    test "start bucket with persistor", %{filename: filename} do
      {:ok, _pid} = Server.new_bucket(:test, Persistor.File, filename: filename)
      Server.persist(:test)
      refute Server.dirty?(:test)
    end

    test "bucket knows it's persistor", %{filename: filename} do
      {:ok, _pid} =
        Server.new_bucket(:file_test, Persistor.File, filename: filename)

      assert {Persistor.File, filename: filename} == Server.persistor(:file_test)
    end

    test "bucket stores to file", %{filename: filename} do
      {:ok, _pid} =
        Server.new_bucket(:file_test, Persistor.File, filename: filename)

      Server.insert_new(:file_test, %{name: "Some entry"})
      assert Server.dirty?(:file_test)

      Server.persist(:file_test)
      refute Server.dirty?(:file_test)

      assert File.exists?(filename)
    end

    test "bucket reads from file", %{filename: filename} do
      {:ok, pid} =
        Server.new_bucket(:file_test, Persistor.File, filename: filename)

      {:ok, {id, _}} = Server.insert_new(:file_test, %{name: "Some entry"})

      assert Server.dirty?(:file_test)

      Server.persist(:file_test)
      refute Server.dirty?(:file_test)
      Process.exit(pid, :kaboom)

      refute Process.alive?(pid)
      assert File.exists?(filename)

      assert {:ok, %{name: "Some entry"}} = Server.get(:file_test, id)
    end
  end
end
