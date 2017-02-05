defmodule Formex.TestModel.Article do
  use Formex.TestModel

  schema "articles" do
    field :title, :string
    field :content, :string
    field :visible, :boolean

    belongs_to :category, App.Category

    timestamps()
  end
end
