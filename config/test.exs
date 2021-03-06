use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :codesio, CodesioWeb.Endpoint,
  http: [port: 4001],
  server: false,
  debug_errors: false

config :elastix,
  shield: true
config :comeonin,
  bcrypt_log_rounds: 4
config :elastix,
  httpoison_options: [hackney: [pool: :elastix_pool]]
# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :codesio, Codesio.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "codesio_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
