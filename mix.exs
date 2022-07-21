defmodule Qnotix.MixProject do
  use Mix.Project

  def project do
    [
      app: :qnotix,
      version: "1.0.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      name: "Qnotix",
      description: description(),
      source_url: "https://github.com/huqedato/qnotix"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Qnotix.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Qnotix is a Pub/Sub notification system developed in Elixir and based on just `Plug Cowboy` module and websockets."
  end

  defp package do
    [
      files: ~w(lib config .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["AGPL-3.0-or-later"],
      links: %{"GitHub" => "https://github.com/huqedato/qnotix"}
    ]
  end
end
