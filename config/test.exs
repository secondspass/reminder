use Mix.Config

config :reminder,
  to_email: "to@gmail.com",
  from_email: "from@gmail.com",
  db: 'priv/rems_test.db'

config :mailman,
  store_deliveries: true
