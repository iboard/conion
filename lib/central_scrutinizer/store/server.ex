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

  ## Server API
  ######################################################################

  # GenServer Callbacks
  ######################################################################

  @impl true
  def handle_call({:persistor, bucket}, _, state) do
    {:reply, Bucket.persistor(bucket), state}
  end

  def handle_call(:list_buckets, _, state) do
    try do
      {:reply, BucketSupervisor.list_buckets(), state}
    catch
      _ -> {:reply, [], state}
    end
  end

  def handle_call({:new_bucket, name}, _, _state) do
    initial_state = %{bucket_name: name}

    {:ok, pid} =
      BucketSupervisor.start_child(initial_state: initial_state)

    Bucket.drop!(pid)
    {:reply, {:ok, pid}, initial_state}
  end

  def handle_call({:new_bucket, name, persistor, args}, _, _) do
    initial_state =
      %{bucket_name: name, persistor: persistor, args: args}

    {:ok, pid} =
      BucketSupervisor.start_child(initial_state: initial_state)

    {:reply, {:ok, pid}, initial_state}
  end
end
