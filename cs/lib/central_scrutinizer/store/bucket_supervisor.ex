defmodule CentralScrutinizer.Store.BucketSupervisor do
  @moduledoc """
  A `DynamicSupervisor` whith `Bucket` children.
  """

  use DynamicSupervisor
  alias CentralScrutinizer.Store.Bucket

  @doc "Started from `CentralScrutinizer.Application`"
  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns a list of bucket-names of all Buckets alive.
  """
  def list_buckets() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, pid, :worker, [CentralScrutinizer.Store.Bucket]} ->
      Bucket.bucket_name(pid) 
    end)
  end

  @doc """
  Starts a new Bucket if not running yet.
  Returns {:ok, pid}
  """
  def start_child(args) do
    name=args[:initial_state][:bucket_name]

    case DynamicSupervisor.start_child(
           __MODULE__,
           {CentralScrutinizer.Store.Bucket, name: :"bucket_#{name}", bucket_name: name}
         ) do
      {:ok, pid} when is_pid(pid) -> {:ok, pid}
      {:error, {:already_started, pid}} when is_pid(pid) -> 
        {:ok, pid}
    end
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

end
