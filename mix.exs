defmodule Codex.MixProject do
  use Mix.Project
  @url "https://github.com/maartenvanvliet/codex"

  def project do
    [
      app: :codex,
      version: "0.9.2",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @url,
      homepage_url: @url,
      consolidate_protocols: Mix.env() != :test,
      description: "Library to facilitate control flow, providing a Plug like interface.",
      package: [
        maintainers: ["Maarten van Vliet"],
        licenses: ["MIT"],
        links: %{"GitHub" => @url},
        files: ~w(LICENSE README.md lib mix.exs .formatter.exs)
      ],
      docs: [
        main: "Codex",
        canonical: "http://hexdocs.pm/codex",
        source_url: @url
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stream_data, "~> 0.4", optional: true},
      {:norm, "~> 0.12.0", optional: true},
      {:ex_doc, "~> 0.23", only: [:dev, :test]},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end
end
