defmodule Formex.ViewTestTagType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:name, :text_input)
  end
end

defmodule Formex.ViewTestType do
  use Formex.Type
  alias Formex.TestModel.Tag

  def build_form(form) do
    form
    |> add(
      :title,
      :text_input,
      phoenix_opts: [
        class: "some-class"
      ]
    )
    |> add(:content, :textarea)
    |> add(:visible, :checkbox, required: false)
    |> add(:tags, Formex.ViewTestTagType, struct_module: Tag)
    |> add(
      :category_id,
      :select,
      choices: ["Elixir": 1, PHP: 2],
      phoenix_opts: [
        prompt: "Choose a category"
      ]
    )
    |> add(
      :save,
      :submit,
      label: "Submit form",
      phoenix_opts: [
        class: "btn-success"
      ]
    )
  end
end

defmodule Formex.ViewTest do
  use Formex.TestCase
  import Formex.Builder
  alias Formex.ViewTestType
  alias Formex.TestModel.Article

  test "render view" do
    tags = Enum.map(1..14, &%{id: &1, name: "tag-#{&1}", formex_id: &1})

    form = create_form(ViewTestType, %Article{tags: tags})

    {:safe, form_html} =
      Formex.View.formex_form_for(form, "", fn f ->
        Formex.View.formex_rows(f)
      end)

    form_html = to_string(form_html)

    assert String.match?(form_html, ~r/some-class/)
    assert String.match?(form_html, ~r/Choose a category/)
    assert String.match?(form_html, ~r/PHP/)
    assert String.match?(form_html, ~r/Submit form/)
    assert String.match?(form_html, ~r/btn-success/)

    tags_ordered = Enum.map(tags, & &1.name) |> Enum.join(".+")
    tags_ordered_regex = ~r/#{tags_ordered}/
    assert String.match?(form_html, tags_ordered_regex)

    {:safe, form_html} =
      Formex.View.formex_form_for(form, "", fn f ->
        Formex.View.formex_input(f, :title)
      end)

    form_html = to_string(form_html)
    assert String.match?(form_html, ~r/id="article_title"/)
    assert !String.match?(form_html, ~r/for="article_title"/)

    {:safe, form_html} =
      Formex.View.formex_form_for(form, "", fn f ->
        Formex.View.formex_label(f, :title)
      end)

    form_html = to_string(form_html)
    assert !String.match?(form_html, ~r/id="article_title"/)
    assert String.match?(form_html, ~r/for="article_title"/)
  end
end
