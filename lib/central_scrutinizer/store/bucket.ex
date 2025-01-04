defmodule CentralScrutinizer.Store.Bucket do
  @moduledoc """
  A Bucket is a key/value store in a supervised GenServer.
  Use `CentralScrutinizer.Store.Server.new_bucket/1` to start a bucket.
  The Server will use `CentralScrutinizer.Store.BucketSupervisor.start_child/1`
  to do so.
  """

  ## CommonServer implementation
  ######################################################################
  use CentralScrutinizer.CommonServer

  def prepare_state_to_start(args) do
    %{bucket_name: args[:bucket_name], bucket: %{}}
  end

  ## Bucket API
  ######################################################################

  @doc ~s"""
  Return the bucket name of the bucket at `pid`
  """
  def bucket_name(pid), do: call(pid, :bucket_name)

  @doc ~s"""
  Return the entry at id from the bucket
  """
  def get(bucket, id), do: call(process_name(bucket), {:get, id})

  @doc ~s"""
  Return all entry from the bucket
  """
  def list(bucket), do: call(process_name(bucket), :list)

  @doc ~s"""
  removes all entries from the bucket
  """
  def drop!(pid), do: call(pid, :drop!)

  @doc ~s"""
  `{:ok, {new_id,etry}}, {:error, :bucket_not_exist}`
  """
  def insert(bucket, entry), do: call(process_name(bucket), {:insert, entry})

  @doc ~s"""
  `{:ok, {id,etry}}, {:error, :bucket_not_exist | :id_not_found}`
  """
  def replace(bucket, id, entry), do: call(process_name(bucket), {:replace, id, entry})

  @doc ~s"""
  `{:ok, {id,etry}}, {:error, :bucket_not_exist | :id_not_found}`
  """
  def remove(bucket, id), do: call(process_name(bucket), {:remove, id})

  ## GenServer Callbacks Implementation
  ######################################################################

  @impl true
  def handle_call(:drop!, _, %{bucket: _bucket} = state),
    do: {:reply, :ok, %{state | bucket: %{}}}

  def handle_call(:bucket_name, _, %{bucket_name: name} = state),
    do: {:reply, name, state}

  def handle_call(:bucket_name, _, unsupported = state),
    do: {:reply, {:bucket_doesnt_exist, unsupported}, state}

  def handle_call({:get, id}, _, %{bucket: bucket} = state),
    do: {:reply, entry_or_error(bucket, id), state}

  def handle_call(:list, _, %{bucket: bucket} = state),
    do: {:reply, Enum.map(bucket, & &1), state}

  def handle_call({:insert, entry}, _, %{bucket: bucket} = state) do
    with_unique_id(fn id ->
      {:reply, {:ok, {id, entry}}, %{state | bucket: Map.put(bucket, id, entry)}}
    end)
  end

  def handle_call({:replace, id, entry}, _, %{bucket: bucket} = state) do
    {reply, new_state} = replace_or_error(state, bucket, id, entry)
    {:reply, reply, new_state}
  end

  def handle_call({:remove, id}, _, %{bucket: bucket} = state) do
    {reply, new_state} = remove_or_error(state, bucket, id)
    {:reply, reply, new_state}
  end

  # private implementation details
  ###########################################################################

  # "Return the process name at which this bucket is registered"
  defp process_name(bucket_name), do: :"bucket_#{bucket_name}"

  defp entry_or_error(bucket, id) do
    if Map.has_key?(bucket, id),
      do: {:ok, bucket[id]},
      else: id_not_found(id)
  end

  defp replace_or_error(state, bucket, id, entry) do
    (Map.has_key?(bucket, id) &&
       {{:ok, entry}, %{state | bucket: Map.put(bucket, id, entry)}}) ||
      id_not_found(id)
  end

  defp remove_or_error(state, bucket, id) do
    (Map.has_key?(bucket, id) &&
       {{:ok, Map.get(bucket, id)}, %{state | bucket: Map.delete(bucket, id)}}) ||
      id_not_found(id)
  end

  defp id_not_found(id), do: {:error, {:id_not_found, id}}

  defp with_unique_id(func) do
    func.(UUID.uuid4())
  end
end
