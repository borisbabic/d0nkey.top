defmodule Backend.MixProject do
  use Mix.Project

  def project do
    [
      app: :backend,
      version: "0.1.0",
      sourcerorversion: "~> 1.0.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
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
      {:cowlib, "~> 2.13", override: true},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_live_dashboard, "~> 0.7"},
      {:phoenix_view, "~> 2.0"},
      {:telemetry_poller, "~> 1.1"},
      {:telemetry_metrics, "~> 1.0"},
      {:torch, "~> 5.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.1"},
      {:httpoison, "~> 2.1"},
      {:poison, "~> 6.0"},
      {:recase, "~> 0.5"},
      {:nostrum, "~> 0.10", runtime: Mix.env() in [:dev, :bot]},
      # nostrum wants 2.0, tesla wants less, but it's optional there
      {:gun, "~> 2.0", override: true},
      {:typed_struct, "~> 0.3"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      # decoding decks stops working with larger (or at least with 1.4)
      {:varint, "~> 1.0.1"},
      {:timex, "~> 3.5"},
      {:floki, ">= 0.27.0"},
      {:tesla, "~> 1.4"},
      {:tesla_cache, "~> 1.1.0"},
      {:guardian, "~> 2.0"},
      {:ueberauth_bnet,
       github: "borisbabic/ueberauth_bnet", commit: "8f57a3ae0b6fcc74b341a5ff7a410443501577e4"},
      # {:ueberauth_bnet, "~> 0.3"},
      # {:ueberauth_bnet, path: "/home/boris/projects/ueberauth_bnet"},
      {:ueberauth_twitch, "~> 0.2.0"},
      # {:ueberauth_patreon, "~> 1.0"},
      {:ueberauth_patreon, github: "borisbabic/ueberauth_patreon"},
      # {:ueberauth_patreon, path: "/home/boris/projects/ueberauth_patreon"}3
      {:countriex, "~>0.4"},
      {:absinthe, "~> 1.5"},
      {:absinthe_plug, "~> 1.5"},
      {:absinthe_phoenix, "~> 2.0.0"},
      {:absinthe_relay, "~> 1.5"},
      {:surface, "~> 0.9"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:oban, "~> 2.5"},
      {:phoenix_meta_tags, github: "javiercr/phoenix_meta_tags"},
      {:oauther, "~> 1.1"},
      {:extwitter, "~> 0.12"},
      {:bcrypt_elixir, "~> 3.3"},
      {:table_rex, "~> 4.0"},
      {:contex, "~> 0.4"},
      {:tmi, "~> 0.7"},
      {:etop, "~> 0.7"},
      {:solid, "~> 0.10"},
      {:ecto_psql_extras, "~> 0.6"},
      {:csv, "~> 3.2"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:akin, "~> 0.1"},
      {:error_tracker, "~> 0.1"},
      {:oban_live_dashboard, "~> 0.2.0"},
      {:kaffy, "~> 0.10.0"},
      {:quantum, "~> 3.5"}
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
      # "run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
