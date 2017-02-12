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

defmodule Formex.SelectAssoc.QueryTest do
  use Formex.SelectAssocCase
  alias Formex.SelectAssocChoiceQueryTestType

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
