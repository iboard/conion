defmodule Cea.Common.Logger do
  @moduledoc """
  Wrapper around the default `Logger`. Always use the
  #{__MODULE__}.log/1 to do logging. This ensures all
  log messages are formatted the same and are easy to 
  read and configure in a single place.
  """
  alias Logger, as: L
  require L

  @doc """
  The `element` is passed through the function, so you can
  use this function in a pipe.

    `element` ..... the element to log and return at the end
    `level` ....... log in which LOG_LEVEL
    `message` ..... the text to prepend to the element inspect

  """
  def log(element, level, message) do
    L.log(level, message <> "->" <> inspect(element, pretty: true))
    element
  end

  @doc """
  Call the system's `Logger.configure/1` function.
  """
  def configure(config), do: L.configure(config)
end
