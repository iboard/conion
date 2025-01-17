defmodule ConionTest do
  use ExUnit.Case
  doctest Conion

  test "all parts are started with the application" do
    assert Conion.alive?()

    for {module, _args} <- Conion.application_children() do
      assert GenServer.whereis(module), "Module #{module} should be alive but isn't."
    end
  end
end
