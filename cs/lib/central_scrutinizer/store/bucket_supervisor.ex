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
    |> Enum.map(&get_bucket_name/1)
  end

  @doc """
  Starts a new Bucket if not running yet.
  Returns {:ok, pid}
  """
  def start_child(args) do
    name = args[:initial_state][:bucket_name]

    DynamicSupervisor.start_child(
      __MODULE__,
      {Bucket, name: :"bucket_#{name}", bucket_name: name}
    )
    |> handle_start_child()
  end

  # DynamicSupervisor Callbacks

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # private implementation

  defp handle_start_child(result) do
    case result do
      {:ok, pid} when is_pid(pid) ->
        {:ok, pid}

      {:error, {:already_started, pid}} when is_pid(pid) ->
        {:ok, pid}
    end
  end

  defp get_bucket_name({_, pid, :worker, [Bucket]}) do
    Bucket.bucket_name(pid)
  end
end
