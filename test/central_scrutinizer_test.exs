defmodule CentralScrutinizerTest do
  use ExUnit.Case
  doctest CentralScrutinizer

  test "all parts are started with the application" do
    assert CentralScrutinizer.alive?()

    for {module, _args} <- CentralScrutinizer.application_children() do
      assert GenServer.whereis(module), "Module #{module} should be alive but isn't."
    end
  end
end
