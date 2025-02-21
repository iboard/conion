defmodule StoreTest do
  use ExUnit.Case
  alias Conion.Store

  test ".list_buckets()" do
    assert is_list(Store.list_buckets())
  end

  test ".new_bucket('name')" do
    assert {:ok, _pid} = Store.new_bucket(:my_bucket)
    assert :my_bucket in Store.list_buckets()
  end

  test ".insert_new(bucket,entry)" do
    {:ok, _pid} = Store.new_bucket(:my_bucket)
    {:ok, {id, entry}} = Store.insert_new(:my_bucket, %{some: :thing})

    assert not is_nil(id)
    assert entry == %{some: :thing}
  end

  test ".list(bucket)" do
    {:ok, _pid} = Store.new_bucket(:some_bucket)
    {:ok, {id1, entry1}} = Store.insert_new(:some_bucket, %{name: "1_entry"})
    {:ok, {id2, entry2}} = Store.insert_new(:some_bucket, %{name: "2_entry"})
    {:ok, {id3, entry3}} = Store.insert_new(:some_bucket, %{name: "3_entry"})

    assert [{^id1, ^entry1}, {^id2, ^entry2}, {^id3, ^entry3}] =
             Store.list(:some_bucket) |> Store.sort_by(fn {_id, entry} -> entry[:name] end)
  end

  test ".get(bucket,id)" do
    {:ok, _pid} = Store.new_bucket(:my_bucket)
    {:ok, {id1, entry1}} = Store.insert_new(:my_bucket, %{some: :thing})
    {:ok, {id2, entry2}} = Store.insert_new(:my_bucket, %{some: :other_thing})

    {:ok, ^entry1} = Store.get(:my_bucket, id1)
    {:ok, ^entry2} = Store.get(:my_bucket, id2)
  end

  test ".get(bucket,id)" do
    {:ok, _pid} = Store.new_bucket(:my_bucket)
    {:ok, {id1, entry1}} = Store.insert_new(:my_bucket, %{some: :thing})
    {:ok, {id2, entry2}} = Store.insert_new(:my_bucket, %{some: :other_thing})

    {:ok, ^entry1} = Store.get(:my_bucket, id1)
    {:ok, ^entry2} = Store.get(:my_bucket, id2)
  end

  test ".get(non_existing_bucket, id)" do
    {:ok, _pid} = Store.new_bucket(:my_bucket)
    {:ok, {id, _entry}} = Store.insert_new(:my_bucket, %{some: :thing})
    {:error, {:not_alive, nil}} = Store.get(:nix_bucket, id)
  end

  test ".get(bucket,non_existing_id)" do
    {:ok, _pid} = Store.new_bucket(:my_bucket)
    {:ok, {_id, _entry}} = Store.insert_new(:my_bucket, %{some: :thing})
    {:error, {:id_not_found, :my_123}} = Store.get(:my_bucket, :my_123)
  end

  test ".update(bucket,id,entry)" do
    {:ok, _pid} = Store.new_bucket(:my_bucket)
    {:ok, {id, entry}} = Store.insert_new(:my_bucket, %{some: :thing})
    {:ok, updated_entry} = Store.replace(:my_bucket, id, %{entry | some: "updated thing"})

    assert updated_entry[:some] == "updated thing"
    {:ok, reloaded_entry} = Store.get(:my_bucket, id)
    assert reloaded_entry[:some] == "updated thing"
  end

  test ".update(non_existing_bucket,_) returns error" do
    entry = %{some: "thing"}

    {:error, {:not_alive, _}} =
      Store.replace(:not_existing_bucket, "doesnt_matter", %{entry | some: "updated thing"})
  end

  test ".update(bucket,non_existing_key, \"doesnt matter\") returns error" do
    {:ok, _pid} = Store.new_bucket(:some_new_bucket)

    assert :error ==
             Store.replace(:some_new_bucket, "non_existing_id", %{some: "updated thing"})
  end

  test ".delete(bucket,id)" do
    {:ok, _pid} = Store.new_bucket(:my_bucket)
    {:ok, {id1, entry1}} = Store.insert_new(:my_bucket, %{some: :one})
    {:ok, {_id2, _entry2}} = Store.insert_new(:my_bucket, %{some: :two})
    {:ok, deleted_entry} = Store.remove(:my_bucket, id1)

    assert entry1 == deleted_entry
    assert {:error, {:id_not_found, ^id1}} = Store.get(:my_bucket, id1)
  end

  @tag :slow
  test "insert 10_000 entries in less than   110ms" do
    {:ok, _pid} = Store.new_bucket(:my_bucket)

    s = :os.system_time()

    for i <- 1..10_000 do
      Store.insert_new(:my_bucket, %{entry: "#{i}"})
    end

    e = :os.system_time()

    # e and s are nanoseconds
    assert div(e - s, 1000 * 1000) < 110
  end

  @tag :slow
  test "insert 100_000 entries in less than 1010ms" do
    {:ok, _pid} = Store.new_bucket(:my_bucket)

    s = :os.system_time()

    for i <- 1..100_000 do
      Store.insert_new(:my_bucket, %{entry: "#{i}"})
    end

    e = :os.system_time()

    # e and s are nanoseconds
    assert div(e - s, 1000 * 1000) < 1010
  end
end
