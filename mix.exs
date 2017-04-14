defmodule Formex.Mixfile do
  use Mix.Project

  def project do
    [app: :formex,
     version: "0.4.9",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     description: description(),

     docs: [main: "readme",
          extras: ["README.md"]],
     source_url: "https://github.com/jakub-zawislak/formex",
     elixirc_paths: elixirc_paths(Mix.env),
     aliases: aliases()
   ]
  end

  def application do
    []
  end

  defp deps do
    [{:phoenix_html, "~> 2.0"},
     {:ecto, "~> 2.0"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:postgrex, ">= 0.0.0", only: [:dev, :test]}, # without a :dev the jakub-zawislak/phoenix-forms won't start. maybe should be removed
     {:phoenix, "~> 1.2", only: [:dev, :test]},
     {:phoenix_ecto, "~> 3.0", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Formex is an abstract layer that helps to build forms in Phoenix and Ecto
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

  defp aliases do
    ["test": ["ecto.migrate", "test"]]
  end
end
