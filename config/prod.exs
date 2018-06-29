use Mix.Config

config :reminder, db: 'priv/rems.db'

import_config "prod.secret.exs"
