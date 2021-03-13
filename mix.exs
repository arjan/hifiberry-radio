defmodule Radio.MixProject do
  use Mix.Project

  @app :radio
  @version "0.1.0"
  @all_targets [:hifiberry_rpi0]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      archives: [nerves_bootstrap: "~> 1.9"],
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Radio.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:paracusia, path: "../../paracusia"},
      {:porcelain, "~> 2.0"},
      {:observer_cli, "~> 1.5"},
      {:circuits_uart, "~> 1.3"},

      # Dependencies for all targets
      {:nerves, "~> 1.6.3", runtime: false},
      {:phoenix_live_view, "~> 0.14.6"},
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:shoehorn, "~> 0.6.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.0", targets: @all_targets},

      # Dependencies for specific targets
      {:hifiberry_rpi0,
       path: "../hifiberry_rpi0",
       runtime: false,
       targets: :hifiberry_rpi0,
       nerves: [compile: true]}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
