defmodule Formex.Mixfile do
  use Mix.Project

  def project do
    [app: :formex,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    []
  end

  defp deps do
    [{:ecto, "~> 2.1"}]
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
