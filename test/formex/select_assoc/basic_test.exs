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

defmodule Formex.SelectAssoc.BasicTest do
  use Formex.SelectAssocCase
  alias Formex.SelectAssocBasicTestType

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

end
