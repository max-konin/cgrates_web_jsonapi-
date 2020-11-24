defmodule CgratesWebJsonapi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cgrates_web_jsonapi,
      version: "0.3.0",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      test_coverage: [tool: Coverex.Task, coveralls: true],
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {CgratesWebJsonapi.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.3"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_live_dashboard, "~> 0.2.0"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:jason, "~> 1.0"},
      {:bureaucrat, "~> 0.1.4", runtime: false},
      {:comeonin, "~> 2.0"},
      {:cors_plug, "~> 1.2"},
      {:coverex, "~> 1.4.10", only: :test},
      {:credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false},
      {:csv, "~> 2.0.0"},
      {:distillery, "~> 2.1", runtime: false},
      {:ecto_conditionals, "~> 0.1.0"},
      {:ecto_sql, "~> 3.4"},
      {:ex_machina, "~> 2.4", only: :test},
      {:faker, "~> 0.8", only: :test},
      {:guardian, "~> 2.0"},
      {:httpoison, "~> 0.13"},
      {:ja_resource, github: "vt-elixir/ja_resource"},
      {:ja_serializer, "~> 0.16.0"},
      {:mapail, "~> 1.0"},
      {:mock, "~> 0.3.6", only: :test},
      {:parallel_stream, "~> 1.0.5"},
      {:postgrex, ">= 0.0.0"},
      {:proper_case, github: "max-konin/proper_case", branch: "upper-case"},
      {:scrivener_ecto, "~> 2.0"},
      {:uuid, "~> 1.1"},
      {:husky, "~> 1.0", only: :dev, runtime: false}
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
      "ecto.setup": ["ecto.create", "ecto.load", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.drop", "ecto.create --quiet", "ecto.load", "ecto.migrate", "test"]
    ]
  end
end
