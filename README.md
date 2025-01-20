# Conion

[![.github/workflows/elixir.yml](https://github.com/iboard/conion/actions/workflows/elixir.yml/badge.svg)](https://github.com/iboard/conion/actions/workflows/elixir.yml)

Conion is a package containing an Elixir application that provides some 
common modules for general tasks in your Elixir application.

**At the moment, this is just a POC. Lets see how mature this application can get.**

### A persistent, supervised key/value store
- A key/value store (`Conion.Store`) that handles `Conion.Store.Bucket`s
  - The `Conion.Store.Persistor` is a `Behaviour` that implements `read!` and `write!`
    for those buckets.
- Buckets are supervised
- A central `Conion.Common.Configuration` module to deal with compile and runtime
  configuration.
- A central `Conion.Common.CentralLogger` module to do logging in a common manner.

...more to come

## Install and prepare

    git clone https://github.com/iboard/conion.git
    cd conion
    mkdir -p data/test data/dev
    mix test
    
## Use it as a dependency in your `mix.exs`

```
  defp deps do
    [
      { :conion, "~> 0.1"}
    ]

```

Find the package on [hex.pm](https://hex.pm/packages/conion)

## Usage Examples

You can find a complete LiveView application at [Coex](https://github.com/iboard/coex) using
Conion as the backend storage.

### Configuration

Define the following function in your top module

```
  def configurations,
    do: [
      # { {ENV,      :app,    :key, default}, set-function/1                }
      {{"LOG_LEVEL", :logger, :level, :info}, &Configuration.set_log_level/1}
    ]
```

and use it like

```
  def configure(),
    do:
      configurations()
      |> Enum.reduce(%{}, &Configuration.load_configuration_for/2)

```

### CentralLogger

```
  use Conion.Common.CentralLogger
  
  def .... do 
    log(element_to_log, :warning, "Any message" )
  end
```

`:warning` is an example for any log-level (:info, :notice, :warning, :error, ...)
The `element_to_log` will be "inspected" and passed through, thus you can use this
log-function in a pipe.

### CommonServer

To define your GenServers use ...

```
  use Conion.CommonServer
  
  def prepare_state_to_start(args) do
    # define any term that will be passed to `start_link(__MODULE__, state)` as
    # the initial state passed to GenServer's `init` function.
  end

  def initial_state(init_state_from_prepare_function) do
    # complete the "loading", "initializing" in the GenServer's init-callback here.
  end

  # use the `call/2` function to safely call a "handle_call" or "handle_cast"
  def bucket_name(pid), do: call(pid, :bucket_name)
  def persist(bucket), do: cast(process_name(bucket), :persist)
  
  # and implement the callbacks as usual
  def handle_call(:bucket_name, _, state), do: calculate_the_return; {:reply, state[:name], state}
  def handle_cast(:persist, state), do: do_something; {:noreply, state}
```

### Store

`Store.Persistor.File` is a simple implementation of the `Store.Persistor` behaviour
that writes the data into the given file, using `:erlang.term_to_binary` and reads it back
using `:erlang.binary_to_term`

More implementations of "persistors" will follow.

```
alias CentralScrutinizer.Store
Store.new_bucket :family, Store.Persistor.File, filename: "data/dev/family.data"
# where `Store.Persistor.File` implements the `Persistor`-behaviour and writes the data to the
# given file.

{:ok, id_father} = Store.insert_new(:family, %{ name: "Father", age: 50})
{:ok, id_mother} = Store.insert_new(:family, %{ name: "Mother", age: 45})
{:ok, id_child} = Store.insert_new(:family, %{ name: "Child", age: 5})
Store.list(:family)
# [ {id, %{...}}, {id, %{...}}, ...]
Store.replace(:family, id_father, %{ name: "Papa", age: 51})
Store.get(:family, id_father) # => %{ name: "Papa", age: 51}
Store.remove(:family, id_father)
Store.persist(:family)

```

## Generate an XREF image

to create an xref-graph use the following command:

    mix xref graph --format dot  && \
    dot -Tpng xref_graph.dot -o xref_graph.png && \
    open xref_graph.png && \
    sleep 5 && rm xref_graph.*

## Generate documentation

    mix docs && open doc/index.html
