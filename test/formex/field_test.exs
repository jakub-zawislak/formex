defmodule Formex.FieldTestType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:title, :text_input, custom_value: fn val -> "custom_"<>val end)
    |> add(:save, :submit)
  end
end

defmodule Formex.FieldTest do
  use Formex.TestCase
  use Formex.Controller
  alias Formex.FieldTestType
  alias Formex.TestModel.Article

  test "change_value option" do
    form = create_form(FieldTestType, %Article{title: "title"})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_html = to_string(form_html)

    assert String.match?(form_html, ~r/value="custom_title"/)
  end

end
