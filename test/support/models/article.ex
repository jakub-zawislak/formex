defmodule Formex.TestModel.Article do
  use Formex.TestModel

  schema "articles" do
    field :title, :string
    field :content, :string
    field :visible, :boolean

    belongs_to :category, Formex.TestModel.Category
    belongs_to :user, Formex.TestModel.User

    many_to_many :tags, Formex.TestModel.Tag, join_through: "articles_tags",
      on_delete: :delete_all, on_replace: :delete

    timestamps()
  end
end
