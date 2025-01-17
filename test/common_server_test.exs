defmodule CommonServerTest do
  use ExUnit.Case

  defmodule MyNamelessServer do
    use Conion.CommonServer
  end

  defmodule MyNamedServer do
    use Conion.CommonServer
  end

  defmodule MySpecialServer do
    use Conion.CommonServer

    def initial_state(_) do
      :my_special_initial_state
    end
  end

  test "start nameless server with state" do
    {:ok, pid} = MyNamelessServer.start_link(:my_state)

    assert :sys.get_state(pid) == :my_state
  end

  test "start named server" do
    {:ok, pid} = MyNamedServer.start_link(name: :my_server, initial_state: :my_state)

    assert ^pid = Process.whereis(:my_server)
    assert :sys.get_state(pid) == :my_state
  end

  test "start with overwritten initial_state" do
    {:ok, pid} = MySpecialServer.start_link(:my_state)
    assert :sys.get_state(pid) == :my_special_initial_state
  end

  test "get_state(pid)" do
    {:ok, pid} = MyNamelessServer.start_link(:my_state)

    assert MyNamelessServer.get_state(pid) == :my_state
  end

  test "get_state(:name)" do
    {:ok, _pid} = MyNamelessServer.start_link(name: :my_named_server, initial_state: :my_state)

    assert MyNamelessServer.get_state(:my_named_server) == :my_state
  end
end
