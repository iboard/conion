defmodule CentralScrutinizer.CommonServer do
  @moduledoc """
  `use CommonServer` defines some boilerplate functions for a GenServer.


  """
  @callback prepare_start(arg :: any()) :: any()
  @callback initial_state(arg :: any()) :: any()

  defmacro __using__(_opts \\ []) do
    quote do
      use GenServer
      alias Cea.Common.Logger

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
        |> Logger.log(:notice, "#{__MODULE__} started with opts: #{inspect(opts)}")
      end

      def start_link(state) do
        state = state |> prepare_state_to_start()

        GenServer.start_link(__MODULE__, state, [])
        |> Logger.log(:notice, "#{__MODULE__} started unnamed")
      end

      @doc "Returns the state of a server. You can pass an atom or pid."
      def get_state(server) when is_pid(server), do: :sys.get_state(server)
      def get_state(server) when is_atom(server), do: :sys.get_state(server)

      # GenServer Callbacks

      @impl true
      def init(initial_state) do
        {:ok, initial_state(initial_state)}
        |> Logger.log(:debug, "#{__MODULE__} initialized")
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
    end
  end
end
