defmodule Formex.ViewTestType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:title, :text_input, phoenix_opts: [
      class: "some-class"
    ])
    |> add(:content, :textarea)
    |> add(:visible, :checkbox, required: false)
    |> add(:category_id, :select, choices: ["Elixir": 1, "PHP": 2], phoenix_opts: [
      prompt: "Choose a category"
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
      Formex.View.formex_rows(f)
    end)

    form_html = to_string(form_html)

    assert String.match?(form_html, ~r/some-class/)
    assert String.match?(form_html, ~r/Choose a category/)
    assert String.match?(form_html, ~r/PHP/)
    assert String.match?(form_html, ~r/Submit form/)
    assert String.match?(form_html, ~r/btn-success/)

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_input(f, :title)
    end)

    form_html = to_string(form_html)
    assert String.match?(form_html, ~r/id="article_title"/)
    assert !String.match?(form_html, ~r/for="article_title"/)

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_label(f, :title)
    end)

    form_html = to_string(form_html)
    assert !String.match?(form_html, ~r/id="article_title"/)
    assert String.match?(form_html, ~r/for="article_title"/)

  end

end
