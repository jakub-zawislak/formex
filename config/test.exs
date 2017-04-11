use Mix.Config

config :formex, ecto_repos: [Formex.TestRepo]

config :formex,
  repo: Formex.TestRepo,
  translate_error: &Formex.TestErrorHelpers.translate_error/1

config :logger, :console,
  level: :info

# config :formex, Formex.TestRepo,
#   adapter: Ecto.Adapters.Postgres, # postgres is required for schema_embedded tests
#   username: "",
#   password: "",
#   database: "",
#   hostname: "localhost",
#   pool: Ecto.Adapters.SQL.Sandbox,
#   priv: "priv/test_repo"

import_config "test.secret.exs"
