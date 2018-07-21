use Mix.Config

config :reminder,
  db: 'priv/rems_test.db'

config :pre_commit,
  commands: ["test"],
  verbose: true
