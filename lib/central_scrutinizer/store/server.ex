defmodule CentralScrutinizer.Store.Server do
  @moduledoc """
  CentralScrutinizer's Store Server (DataGateway)
  """

  require CentralScrutinizer.Store.BucketSupervisor

  alias CentralScrutinizer.Store.BucketSupervisor
  alias CentralScrutinizer.Store.Bucket

  ## CommonServer implementation
  ######################################################################
  use CentralScrutinizer.CommonServer

  @doc "Start with an empty map (dictionary)"
  def initial_state(_), do: :ok

  ## Server API
  ######################################################################

  ### Bucket functions

  @doc "List all available buckets"
  def list_buckets, do: GenServer.call(__MODULE__, :list_buckets)

  @doc "Create or load a new bucket"
  def new_bucket(name) when is_atom(name) do
    GenServer.call(__MODULE__, {:new_bucket, name})
  end

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

  # GenServer Callbacks
  ######################################################################

  @impl true
  def handle_call(:list_buckets, _, :ok) do
    {:reply, BucketSupervisor.list_buckets(), :ok}
  end

  def handle_call({:new_bucket, name}, _, :ok) do
    {:ok, pid} = BucketSupervisor.start_child(initial_state: %{bucket_name: name})
    Bucket.drop!(pid)
    {:reply, :ok, :ok}
  end
end
