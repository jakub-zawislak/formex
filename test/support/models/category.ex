defmodule Formex.TestModel.Category do
  use Formex.TestModel

  schema "categories" do
    field :name, :string

    timestamps()
  end
end
