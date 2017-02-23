defmodule Formex.SelectAssocBasicTestType do
  use Formex.Type
  require Formex.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(Formex.CustomField.SelectAssoc, :category_id, phoenix_opts: [
      prompt: "Choose category"
    ])
    |> add(Formex.CustomField.SelectAssoc, :tags, phoenix_opts: [
      prompt: "Choose tag"
    ])
  end
end

defmodule Formex.SelectAssoc.BasicTest do
  use Formex.SelectAssocCase
  alias Formex.SelectAssocBasicTestType

  test "basic" do
    insert_categories()
    insert_tags()

    form = create_form(SelectAssocBasicTestType, %Article{})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/asd/)
    assert String.match?(form_str, ~r/tag1/)
    assert String.match?(form_str, ~r/multiple/)
  end

end
