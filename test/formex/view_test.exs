defmodule Formex.ViewTestType do
  use Formex.Type
  require Formex.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:title, :text_input, phoenix_opts: [
      class: "some-class"
    ])
    |> add(:content, :textarea)
    |> add(:visible, :checkbox, required: false)
    |> add(:category_id, Formex.CustomField.SelectAssoc, phoenix_opts: [
      prompt: "Choose category"
    ])
    |> add(:save, :submit, label: "Submit form", phoenix_opts: [
      class: "btn-success"
    ])
  end
end

defmodule Formex.ViewTest do
  use Formex.TestCase
  import Formex.Builder
  alias Formex.ViewTestType
  alias Formex.TestModel.Article

  test "render view" do
    form = create_form(ViewTestType, %Article{})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      f
      |> Formex.View.formex_rows
    end)

    assert form_html
    |> to_string
    |> String.match?(~r/some-class/)

    assert form_html
    |> to_string
    |> String.match?(~r/Choose category/)

    assert form_html
    |> to_string
    |> String.match?(~r/Submit form/)

    assert form_html
    |> to_string
    |> String.match?(~r/btn-success/)

  end

end
