defmodule Formex.TestModel.Article do
  use Formex.TestModel

  schema "articles" do
    field :title, :string
    field :content, :string
    field :visible, :boolean

    belongs_to :category, Formex.TestModel.Category
    belongs_to :user, Formex.TestModel.User

    timestamps()
  end
end
