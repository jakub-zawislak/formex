defmodule Formex.ViewTestType do
  use Formex.Type
  require Formex.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:text_input, :title)
    |> add(:textarea, :content)
    |> add(:checkbox, :visible, required: false)
    |> add(Formex.CustomField.SelectAssoc, :category_id, phoenix_opts: [
      prompt: "Choose category"
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
    |> String.match?(~r/Choose category/)

  end

end
