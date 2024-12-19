defmodule CentralScrutinizer.Application do
  @moduledoc false

  use Application
  use Cea.Common.CentralLogger
  alias CentralScrutinizer, as: CS

  @impl true
  def start(type, args) do
    log({type, args}, :notice, "Starting Application #{__MODULE__} ...")
    CS.configure()

    CS.application_children()
    |> Supervisor.start_link(strategy: :one_for_one, name: CS.Supervisor)
    |> log(:notice, "Starting Application #{__MODULE__} ... started.")
  end
end
