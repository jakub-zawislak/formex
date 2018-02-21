defmodule Formex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :formex,
      version: "0.6.2",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: description(),

      name: "Formex",
      docs: [
        main: "readme",
        extras: ["README.md", "UPGRADE.md", "guides.md"]
      ],
      source_url: "https://github.com/jakub-zawislak/formex",
      elixirc_paths: elixirc_paths(Mix.env)
   ]
  end

  def application do
    []
  end

  defp deps do
    [{:phoenix_html, "~> 2.0"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:phoenix, "~> 1.2", only: [:dev, :test]},
    ]
  end

  defp description do
    """
    Form library for Phoenix with Ecto support
    """
  end

  defp package do
    [maintainers: ["Jakub Zawiślak"],
     licenses: ["MIT"],
     files: ~w(lib priv web CHANGELOG.md LICENSE.md mix.exs package.json README.md),
     links: %{github: "https://github.com/jakub-zawislak/formex"}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
