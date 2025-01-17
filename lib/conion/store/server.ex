defmodule Conion.Store.Server do
  @moduledoc """
  Conion's Store Server (DataGateway)
  """

  require Conion.Store.BucketSupervisor

  alias Conion.Store.BucketSupervisor
  alias Conion.Store.Bucket

  ## CommonServer implementation
  ######################################################################
  use Conion.CommonServer

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
