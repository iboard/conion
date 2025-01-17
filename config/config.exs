# CEA General Config, 2024-11-29 Andreas Altendorfer
#
# Configure common default values here.
# Overwrite this defaults for env,test, and prod mode in the files 
# - dev.exs
# - prod.exs
# - test.exs
#
# Notice: most of the runtime config is loaded from ENV-variables. So,
# definitions here only defines the default for the given mode if no
# ENV is overwriting them.

import Config

config :logger,
  level: String.to_atom(System.get_env("LOG_LEVEL", "info"))

config :cs,
  application_children: [
    {Conion.Store.Server, name: Conion.Store.Server},
    {Conion.Store.BucketSupervisor, name: Conion.Store.BucketSupervisor}
  ]

import_config "#{config_env()}.exs"
