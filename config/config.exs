# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :radio, RadioWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bBUlhYc6s38n26OzmCvODfGpoib47cyRRDsyTyt34wG+ufoIKIhZDNyTUlr6a71P",
  render_errors: [view: RadioWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Radio.PubSub,
  live_view: [signing_salt: "ortlKaQq"]

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay", fwup_conf: "config/fwup.conf"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information
config :nerves, source_date_epoch: "1601715890"

config :phoenix, :json_library, Jason

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

import_config "#{Mix.target()}.exs"

# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :paracusia,
  retry_after: 1000,
  max_retry_attempts: 1000
