defmodule Formex.BuilderTestType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:title, :text_input, validation: [:required])
    |> add(:content, :textarea, validation: [:required])
    |> add(
      :category_id,
      :select,
      choices: [
        "Category A": "1",
        "Category B": "2"
      ],
      validation: [:required]
    )
    |> add(:save, :submit)
  end
end

defmodule Formex.BuilderTest do
  use Formex.TestCase
  use Formex.Controller
  alias Formex.BuilderTestType
  alias Formex.TestModel.Article

  test "create a form" do
    form = create_form(BuilderTestType, %Article{}, %{}, some: :data)
    assert Enum.at(form.items, 0).name == :title
    assert form.opts[:some] == :data
  end

  test "field not required" do
    params = %{"title" => "twoja", "content" => "stara", "category_id" => "1"}
    form = create_form(BuilderTestType, %Article{}, params)

    {:ok, _} = handle_form(form)
  end

  test "field required" do
    params = %{"title" => "szynka"}
    form = create_form(BuilderTestType, %Article{}, params)

    {:error, _} = handle_form(form)
  end

  test "handle form" do
    params = %{"title" => "twoja", "content" => "stara", "category_id" => "1"}
    form = create_form(BuilderTestType, %Article{}, params)

    {:ok, article} = handle_form(form)

    assert article.title == "twoja"
    assert article.content == "stara"
  end
end
