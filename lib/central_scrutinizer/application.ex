defmodule CentralScrutinizer.Application do
  @moduledoc """
  Configures the application and starts the supervision tree.

  Which supervised children to start is configured in the `config.exs` file
  and pulled in from `CentralScrutinizer.application_children/0`.
  """

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
