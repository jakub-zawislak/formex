defmodule Formex.Mixfile do
  use Mix.Project

  def project do
    [app: :formex,
     version: "0.1.3",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     description: description()]
  end

  def application do
    []
  end

  defp deps do
    [{:phoenix_html, "~> 2.0"},
     {:ecto, "~> 2.0"},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp description do
    """
    Formex is an abstract layer that helps to build forms in Phoenix and Ecto
    """
  end

  defp package do
    [maintainers: ["Jakub Zawiślak"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/jakub-zawislak/formex"}]
  end
end
