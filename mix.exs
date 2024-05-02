defmodule Backend.MixProject do
  use Mix.Project

  def project do
    [
      app: :backend,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      preferred_cli_env: [
        "test.watch": :test
      ],
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Backend.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:cowlib, "~> 2.8.0", override: true},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.18"},
      {:phoenix_live_dashboard, "~> 0.7"},
      {:phoenix_view, "~> 2.0"},
      {:telemetry_poller, "~> 0.5"},
      {:telemetry_metrics, "~> 0.6"},
      {:torch, "~> 5.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.1"},
      {:httpoison, "~> 1.6"},
      {:poison, "~> 3.1"},
      {:recase, "~> 0.5"},
      {:nostrum, "~> 0.8", runtime: Mix.env() in [:dev, :bot]},
      # nostrum wants 2.0, tesla wants less, but it's optional there
      {:gun, "~> 2.0", override: true},
      {:typed_struct, "~> 0.1.4"},
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false},
      {:varint, "~> 1.0.0"},
      {:timex, "~> 3.5"},
      {:floki, ">= 0.27.0"},
      {:tesla, "~> 1.4"},
      {:tesla_cache, "~> 1.1.0"},
      {:guardian, "~> 2.0"},
      {:ueberauth_bnet, github: "borisbabic/ueberauth_bnet", branch: "region_fallbacks"},
      # {:ueberauth_bnet, path: "/home/boris/projects/ueberauth_bnet"},
      {:ueberauth_twitch, "~> 0.1.0"},
      # {:ueberauth_patreon, "~> 1.0"},
      {:ueberauth_patreon, github: "borisbabic/ueberauth_patreon"},
      # {:ueberauth_patreon, path: "/home/boris/projects/ueberauth_patreon"},
      {:countriex, "~>0.4"},
      {:absinthe, "~> 1.5.0"},
      {:absinthe_plug, "~> 1.5"},
      {:absinthe_phoenix, "~> 2.0.0"},
      {:absinthe_relay, "~> 1.5.0"},
      {:surface, "~> 0.9"},
      {:wait_for_it, "~>1.1"},
      {:oban, "~> 2.5"},
      {:postgrex_pubsub, "~> 0.2.0"},
      {:phoenix_meta_tags, ">= 0.1.8"},
      {:oauther, "~> 1.1"},
      {:extwitter, "~> 0.12"},
      {:bcrypt_elixir, "~> 2.3.0"},
      {:table_rex, "~> 3.1.1"},
      {:contex, "~> 0.4.0"},
      {:tmi, "~> 0.3.0"},
      {:etop, "~> 0.7"},
      {:solid, "~> 0.10"},
      {:ecto_psql_extras, "~> 0.6"},
      {:csv, "~> 2.5"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:akin, "~> 0.1.8"},
      {:quantum, "~> 2.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
