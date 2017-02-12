defmodule Formex.TestModel.User do
  use Formex.TestModel

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    belongs_to :department, Formex.TestModel.Department

    timestamps()
  end

end
