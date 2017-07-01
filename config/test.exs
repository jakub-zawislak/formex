use Mix.Config

config :formex, ecto_repos: [Formex.TestRepo]

config :formex,
  validator: Formex.Validator.Simple,
  translate_error: &Formex.TestErrorHelpers.translate_error/1

config :logger, :console,
  level: :info
