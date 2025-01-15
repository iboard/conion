defmodule CentralScrutinizer.CommonServer do
  @moduledoc """
  `use CommonServer` defines some boilerplate functions for a GenServer.
  """
  @callback prepare_start(arg :: any()) :: any()
  @callback initial_state(arg :: any()) :: any()

  defmacro __using__(_opts \\ []) do
    quote do
      use GenServer
      use Cea.Common.CentralLogger

      @doc """
      Start the server with either

          MyServer.start_link(initial_state) ... start an unregistered server with the given 
                                                 initial state.

          MyServer.start_link(name: :registered_as_whatever, initial_state: any) ...
                                                 start a registered server with `initial_state` as it's state.
      """
      def start_link(opts) when is_list(opts) do
        GenServer.start_link(
          __MODULE__,
          prepare_state_to_start(opts),
          Keyword.take(opts, [:name])
        )
        |> log(:notice, "#{__MODULE__} started with opts: #{inspect(opts)}")
      end

      def start_link(state) do
        state = state |> prepare_state_to_start()

        GenServer.start_link(__MODULE__, state, [])
        |> log(:notice, "#{__MODULE__} started unnamed")
      end

      @doc "Returns the state of a server. You can pass an atom or pid."
      def get_state(pid_or_atom) when is_pid(pid_or_atom) or is_atom(pid_or_atom),
        do: :sys.get_state(pid_or_atom)

      # GenServer Callbacks

      @impl true
      def init(initial_state) do
        {:ok, initial_state(initial_state)}
        |> log(:debug, "#{__MODULE__} initialized")
      end

      @doc """
      Overridable:

      Should return the args passed to start_link. For a named server it extracts
      the :initial_state from the `opts`. For unnamed processes it takes `opts` as the initial state.
      """
      def prepare_state_to_start(opts) when is_list(opts), do: Keyword.get(opts, :initial_state)
      def prepare_state_to_start(opts), do: opts

      @doc """
      Overridable:

      Prepares, validates, formats the given state to be passed to init()
      """
      def initial_state(state), do: state

      defoverridable prepare_state_to_start: 1
      defoverridable initial_state: 1

      @doc """
      safely call the GenServer.callback 
      return an error tuple if the bucket is not alive
      """
      def call(pid_or_name, message)

      def call(pid, message) when is_pid(pid) do
        Process.alive?(pid)
        |> call_or_error(pid, message)
      end

      def call(name, message) when is_atom(name) do
        pid = GenServer.whereis(name)
        call_or_error(!is_nil(pid), pid, message)
      end

      def call_or_error(true, name_or_pid, message) do
        GenServer.call(name_or_pid, message)
      end

      def call_or_error(false, name_or_pid, _message) do
        {:error, {:not_alive, name_or_pid}}
      end

      @doc """
      safely cast the GenServer.callback 
      return an error tuple if the bucket is not alive
      """
      def cast(pid_or_name, message)

      def cast(name, message) when is_atom(name) do
        pid = GenServer.whereis(name)
        cast_or_error(!is_nil(pid), pid, message)
      end

      def cast(pid, message) when is_pid(pid) do
        Process.alive?(pid)
        |> cast_or_error(pid, message)
      end

      def cast_or_error(true, name_or_pid, message) do
        GenServer.cast(name_or_pid, message)
      end

      def cast_or_error(false, name_or_pid, _message) do
        {:error, {:not_alive, name_or_pid}}
      end
    end
  end
end
