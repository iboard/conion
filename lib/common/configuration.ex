defmodule Conion.Common.Configuration do
  @moduledoc """
  General functions to deal with runtime configuration
  """

  use Conion.Common.CentralLogger

  @doc """
  Loads the environment ENV from `env`. If it is not
  defined, returns the mix-configuration for `app`,
  `key`, `default`. The !-version may raise errors.
  """
  def load!({env, app, key, default} = _conf_key) do
    System.get_env(String.upcase(env)) || Application.get_env(app, key, default)
  end

  @doc """
  Same as `load!/1` but rescue from raise and returns a 
  error tuple `{:error, err}`.
  """
  def load({_env, _app, _key, _default} = conf_key) do
    try do
      load!(conf_key)
    rescue
      err ->
        log(err, :err, "Can't load configuration #{inspect(conf_key)}")
        {:error, err}
    end
  end

  @doc """
  Loads the configuration for a given key `{_env, _app, _key, _default}` and
  calls the `set_function/1` with the loaded value.
  """
  def load_configuration_for({{_env, _app, _key, _default} = conf_key, set_function}, config) do
    loaded = load(conf_key) |> log(:debug, "Configuration loaded")
    set = set_function.(loaded)
    Map.put(config, conf_key, {loaded, set})
  end

  @doc """
  Set the log-level. You can pass one of the following values.
  Either as binary or atom: notice, debug, warning, error
  """
  def set_log_level(level_string_or_atom)

  def set_log_level(level) when is_binary(level) do
    String.to_existing_atom(level)
    |> set_log_level()
  end

  def set_log_level(level) when is_atom(level) do
    :ok = configure(level: level)
  end
end
