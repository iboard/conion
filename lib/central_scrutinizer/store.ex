defmodule CentralScrutinizer.Store do
  @moduledoc """
  The API for the store components `CentralScrutinizer.Store.Server`
  and `CentralScrutinizer.Store.Bucket`.

  Also see the `Behaviour` defined in `CentralScrutinizer.Store.Persistor`
  """
  alias CentralScrutinizer.Store.Server
  alias CentralScrutinizer.Store.Bucket

  ### Bucket functions

  @doc "List all available buckets"
  def list_buckets, do: GenServer.call(Server, :list_buckets)

  @doc "Create or load a new bucket"
  def new_bucket(name) when is_atom(name) do
    GenServer.call(Server, {:new_bucket, name})
  end

  @doc "Create or load a new bucket with a persistor"
  def new_bucket(name, persistor, args) do
    GenServer.call(Server, {:new_bucket, name, persistor, args})
  end

  @doc "Returns the persistor of a bucket"
  def persistor(bucket), do: GenServer.call(Server, {:persistor, bucket})

  ### Entry functions

  @doc "Insert a new entry into an existing bucket"
  def insert_new(bucket, entry) when is_atom(bucket), do: Bucket.insert(bucket, entry)

  @doc "List all entries from the bucket `[{id,entry},...]`"
  def list(bucket) when is_atom(bucket), do: Bucket.list(bucket)

  @doc "Sorts the list of buckets `[{id,entry}, {id, entry}, ...]` by the given function"
  def sort_by(list, func), do: Enum.sort_by(list, func)

  @doc "Get the entry with the given id from the bucket"
  def get(bucket, id) when is_atom(bucket), do: Bucket.get(bucket, id)

  @doc "Update replace the entry at the given id with the new entry"
  def replace(bucket, id, new_entry) when is_atom(bucket),
    do: Bucket.replace(bucket, id, new_entry)

  @doc "remove entry with the given id"
  def remove(bucket, id) when is_atom(bucket), do: Bucket.remove(bucket, id)

  @doc "returns true if the given bucket is not saved permanently"
  def dirty?(bucket), do: Bucket.dirty?(bucket)

  @doc "persist the bucket"
  def persist(bucket), do: Bucket.persist(bucket)
end
