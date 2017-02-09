defmodule Formex.SelectAssocBasicTestType do
  use Formex.Type
  require Formex.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(Formex.CustomField.SelectAssoc, :category_id, phoenix_opts: [
      prompt: "Choose category"
    ])
  end
end

defmodule Formex.SelectAssocChoiceNameAtomTestType do
  use Formex.Type
  require Formex.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(Formex.CustomField.SelectAssoc, :category_id, choice_label: :id)
  end
end

defmodule Formex.SelectAssocChoiceNameFunctionTestType do
  use Formex.Type
  require Formex.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(Formex.CustomField.SelectAssoc, :category_id, choice_label: fn category ->
      category.name <> category.name
    end)
  end
end

defmodule Formex.SelectAssocChoiceQueryTestType do
  use Formex.Type
  require Formex.CustomField.SelectAssoc
  import Ecto.Query

  def build_form(form) do
    form
    |> add(Formex.CustomField.SelectAssoc, :category_id, query: fn query ->
      from e in query,
        where: e.name != "bcd"
    end)
  end
end

defmodule Formex.SelectAssocTest do
  use Formex.TestCase
  import Formex.Builder
  alias Formex.SelectAssocBasicTestType
  alias Formex.SelectAssocChoiceNameAtomTestType
  alias Formex.SelectAssocChoiceNameFunctionTestType
  alias Formex.SelectAssocChoiceQueryTestType
  alias Formex.TestModel.Article
  alias Formex.TestModel.Category
  alias Formex.TestRepo

  def insert_categories() do
    TestRepo.insert(%Category{name: "asd"})
    TestRepo.insert(%Category{name: "bcd"})
    TestRepo.insert(%Category{name: "cfg"})
  end

  test "basic" do
    insert_categories()

    form = create_form(SelectAssocBasicTestType, %Article{})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    assert form_html
    |> to_string
    |> String.match?(~r/asd/)
  end

  test "choice name atom" do
    insert_categories()

    form = create_form(SelectAssocChoiceNameAtomTestType, %Article{})

    choices = Enum.at(form.fields, 0).data[:choices]
    choice  = Enum.at(choices, 0)
    {choice_label, _} = choice
    assert is_number(choice_label)
  end

  test "choice name function" do
    insert_categories()

    form = create_form(SelectAssocChoiceNameFunctionTestType, %Article{})

    choices = Enum.at(form.fields, 0).data[:choices]
    choice  = Enum.at(choices, 0)
    {choice_label, _} = choice
    assert choice_label == "asdasd"
  end

  test "choice query" do
    insert_categories()

    form = create_form(SelectAssocChoiceQueryTestType, %Article{})

    choices = Enum.at(form.fields, 0).data[:choices]

    assert Enum.count(choices) == 2

    {choice0, _} = Enum.at(choices, 0)
    {choice1, _} = Enum.at(choices, 1)

    assert choice0 == "asd"
    assert choice1 == "cfg"
  end

end
