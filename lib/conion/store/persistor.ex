defmodule Conion.Store.Persistor do
  @moduledoc """
  Persistor is a behaviour which implements the low-level read! and write! functions
  to store any kind of data to any kind of storage.
  """

  @doc """
  Writes any kind of data to a store with any name and returns `:ok`
  or raises an exception.
  """
  @callback write!(String.t(), any()) :: :ok

  @doc """
  Reads any kind of data from a store with any name 
  and returns the read data or raises an exception.
  """
  @callback read!(String.t()) :: any()
end
