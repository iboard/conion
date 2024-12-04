defmodule CentralScrutinizer do
  @moduledoc """
  Documentation for `CentralScrutinizer`'s main API.
  """
  alias CentralScrutinizer, as: CS
  alias Cea.Common.{Configuration, Logger}

  # General Configuration

  @doc """
  All confiurations are loaded fro ENV vars. Where the default value for each key is 
  configured in the application's configuration.
  """
  def configurations,
    do: [
      # { {ENV,:app,:key,default}, set-function/1 }
      {{"LOG_LEVEL", :logger, :level, :info}, &Configuration.set_log_level/1}
    ]

  # API

  @doc """
  alive? returns true if the CentralScrutinizer.Server and all it's children are running.
  """
  def alive?(), do: all_up?()

  @doc """
  Return the list of children, that should be started with the `CentralScrutinizer.Application`.
  """
  def application_children(),
    do: Application.get_env(:cs, :application_children, [])

  def configure() do
    configurations()
    |> Enum.reduce(%{}, &Configuration.load_configuration_for/2)
  end

  # Private implementations

  defp all_up?() do
    CS.application_children()
    |> Enum.all?(fn {module, _opts} ->
      not is_nil(GenServer.whereis(module))
      |> tap(fn
        false -> Logger.log(module, :warning, "module is not alive.")
        true -> Logger.log(module, :debug, "module is alive.")
      end)
    end)
  end
end
