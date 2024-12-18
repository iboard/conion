defmodule CentralScrutinizer.Application do
  @moduledoc false

  use Application
  alias CentralScrutinizer, as: CS
  alias Cea.Common.CentralLogger

  @impl true
  def start(type, args) do
    CentralLogger.log({type, args}, :notice, "Starting Application #{__MODULE__} ...")
    CS.configure()

    CS.application_children()
    |> Supervisor.start_link(strategy: :one_for_one, name: CentralScrutinizer.Supervisor)
    |> CentralLogger.log(:notice, "Starting Application #{__MODULE__} ... started.")
  end
end
