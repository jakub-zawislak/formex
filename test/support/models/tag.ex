defmodule Formex.TestModel.Tag do
  use Formex.TestModel

  schema "tags" do
    field :name, :string

    timestamps()
  end
end
