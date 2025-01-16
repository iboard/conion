defmodule BucketTest do
  use ExUnit.Case
  alias CentralScrutinizer.Store
  alias CentralScrutinizer.Store.Persistor

  describe "without persistor" do
    test "a bucket is dirty when modified" do
      {:ok, _pid} = Store.new_bucket(:test)
      refute Store.dirty?(:test)
    end

    test "a bucket is not dirty when persisted" do
      {:ok, _pid} = Store.new_bucket(:test)
      {:ok, _} = Store.insert_new(:test, %{some: :thing})
      assert Store.dirty?(:test)
      Store.persist(:test)
      refute Store.dirty?(:test)
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
      {:ok, _pid} = Store.new_bucket(:test, Persistor.File, filename: filename)
      Store.persist(:test)
      refute Store.dirty?(:test)
    end

    test "bucket knows it's persistor", %{filename: filename} do
      {:ok, _pid} =
        Store.new_bucket(:file_test, Persistor.File, filename: filename)

      assert {Persistor.File, filename: filename} == Store.persistor(:file_test)
    end

    test "bucket stores to file", %{filename: filename} do
      {:ok, _pid} =
        Store.new_bucket(:file_test, Persistor.File, filename: filename)

      Store.insert_new(:file_test, %{name: "Some entry"})
      assert Store.dirty?(:file_test)

      Store.persist(:file_test)
      refute Store.dirty?(:file_test)

      assert File.exists?(filename)
    end

    test "bucket reads from file", %{filename: filename} do
      {:ok, pid} =
        Store.new_bucket(:file_test, Persistor.File, filename: filename)

      {:ok, {id, _}} = Store.insert_new(:file_test, %{name: "Some entry"})

      assert Store.dirty?(:file_test)

      Store.persist(:file_test)
      refute Store.dirty?(:file_test)
      Process.exit(pid, :kaboom)

      refute Process.alive?(pid)
      assert File.exists?(filename)

      assert {:ok, %{name: "Some entry"}} = Store.get(:file_test, id)
    end
  end
end
