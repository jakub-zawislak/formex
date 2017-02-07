use Mix.Config

config :formex, Formex.TestRepo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "root",
  database: "forms-test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "priv/test_repo"

config :formex, ecto_repos: [Formex.TestRepo]

config :formex,
  repo: Formex.TestRepo,
  translate_error: &Formex.TestErrorHelpers.translate_error/1

config :logger, :console,
  level: :info
