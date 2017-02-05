defmodule Formex.BuilderTestTypeArticle do
  use Ecto.Schema

  schema "articles" do
    field :title, :string
    field :content, :string
    field :visible, :boolean

    # belongs_to :category, App.Category

    timestamps()
  end
end

defmodule Formex.BuilderTestType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:text_input, :title, label: "Title")
    |> add(:textarea, :content, label: "Content", phoenix_opts: [
      rows: 4
    ])
    |> add(:textarea, :content, label: "Content", required: false)
  end
end

defmodule Formex.BuilderTest do
  use ExUnit.Case
  import Formex.Builder
  # doctest Formex

  test "create a form" do

    form = create_form(Formex.BuilderTestType, %Formex.BuilderTestTypeArticle{})

    assert form.__struct__ == Formex.Form
  end
end
