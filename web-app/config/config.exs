# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :plant_pulse,
  ecto_repos: [PlantPulse.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :plant_pulse, PlantPulseWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: PlantPulseWeb.ErrorHTML, json: PlantPulseWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PlantPulse.PubSub,
  live_view: [signing_salt: "5ZWuUt3u"]

config :plant_pulse, PlantPulse.MQTTClient,
  client_id: "plant_pulse_client",
  broker_url: "40c4489d8b17431396e6d975f75207a4.s1.eu.hivemq.cloud",
  username: 'plant-pulse-admin',
  password: 'SevenIron1998!'

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :plant_pulse, PlantPulse.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
