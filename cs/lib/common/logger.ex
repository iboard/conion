defmodule Cea.Common.Logger do
  alias Logger, as: L
  require L

  def log(element, level, message) do
    L.log(level, message <> "->" <> inspect(element, pretty: true))
    element
  end

  def configure(config), do: L.configure(config)
end
