defmodule Formex.BuilderTestType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:text_input, :title)
    |> add(:textarea, :content)
    |> add(:checkbox, :visible, required: false)
  end
end

defmodule Formex.BuilderTest do
  use Formex.TestCase
  import Formex.Builder
  alias Formex.BuilderTestType
  alias Formex.TestModel.Article
  alias Formex.TestRepo

  test "create a form" do
    form = create_form(BuilderTestType, %Article{})
    assert Enum.at(form.fields, 0).name == :title
  end

  test "field not required" do
    params = %{title: "twoja", content: "stara"}
    form = create_form(BuilderTestType, %Article{}, params)

    assert form.changeset.valid?
  end

  test "field required" do
    params = %{title: "szynka"}
    form = create_form(BuilderTestType, %Article{}, params)

    refute form.changeset.valid?
  end

  test "database insert" do
    params = %{title: "twoja", content: "stara"}
    form = create_form(BuilderTestType, %Article{}, params)

    {:ok, _} = insert_form_data(form)
  end

  test "database update" do

    article = TestRepo.insert!(%Article{title: "asd", content: "szynka"})

    params = %{content: "cebula"}
    form = create_form(BuilderTestType, article, params)

    {:ok, _} = update_form_data(form)
  end
end
