# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :codesio,
  ecto_repos: [Codesio.Repo]
config :codesio, env: Mix.env
# Configures the endpoint
config :codesio, CodesioWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "++Rk84HSnuXH0hD84gKqK+TbUOdwepCHo7xxqziJPQKPYr++KeX7Aa8SXyMEiKE5",
  render_errors: [view: CodesioWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Codesio.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Codesio.Accounts.User,
  user_token: true,
  repo: Codesio.Repo,
  module: Codesio,
  web_module: CodesioWeb,
  router: CodesioWeb.Router,
  messages_backend: CodesioWeb.Coherence.Messages,
  logged_out_url: "/",
  email_from_name: "Your Name",
  email_from_email: "yourname@example.com",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :invitable, :registerable]
config :torch,
  otp_app: :codesio,
  template_format: "eex" || "slim"
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
import_config "#{Mix.env}.secret.exs"
