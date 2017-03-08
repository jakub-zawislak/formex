defmodule Formex.SelectAssocChoiceLabelAtomTestType do
  use Formex.Type
  require Formex.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:category_id, Formex.CustomField.SelectAssoc, choice_label: :id)
  end
end

defmodule Formex.SelectAssocChoiceLabelFunctionTestType do
  use Formex.Type
  require Formex.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:category_id, Formex.CustomField.SelectAssoc, choice_label: fn category ->
      category.name <> category.name
    end)
  end
end

defmodule Formex.SelectAssoc.ChoiceLabelTest do
  use Formex.SelectAssocCase
  alias Formex.SelectAssocChoiceLabelAtomTestType
  alias Formex.SelectAssocChoiceLabelFunctionTestType

  test "choice label atom" do
    insert_categories()

    form = create_form(SelectAssocChoiceLabelAtomTestType, %Article{})

    choices = Enum.at(form.items, 0).data[:choices]
    choice  = Enum.at(choices, 0)
    {choice_label, _} = choice
    assert is_number(choice_label)
  end

  test "choice label function" do
    insert_categories()

    form = create_form(SelectAssocChoiceLabelFunctionTestType, %Article{})

    choices = Enum.at(form.items, 0).data[:choices]
    choice  = Enum.at(choices, 0)
    {choice_label, _} = choice
    assert choice_label == "asdasd"
  end

end
