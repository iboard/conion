defmodule Conion.Application do
  @moduledoc """
  Configures the application and starts the supervision tree.

  Which supervised children to start is configured in the `config.exs` file
  and pulled in from `Conion.application_children/0`.
  """

  use Application
  use Cea.Common.CentralLogger
  alias Conion

  @impl true
  def start(type, args) do
    log({type, args}, :notice, "Starting Application #{__MODULE__} ...")
    Conion.configure()

    Conion.application_children()
    |> Supervisor.start_link(strategy: :one_for_one, name: Conion.Supervisor)
    |> log(:notice, "Starting Application #{__MODULE__} ... started.")
  end
end
