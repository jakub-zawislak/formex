defmodule Formex.ValidatorTest.DefaultType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:title, :text_input, validation: [:required])
    |> add(:save, :submit)
  end
end

defmodule Formex.ValidatorTest.CustomType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:title, :text_input, validation: [:required])
    |> add(:save, :submit)
  end

  def translate_error do
    fn {_msg, _opts} -> "custom error" end
  end
end

defmodule Formex.ValidatorTest do
  use Formex.TestCase
  use Formex.Controller
  alias Formex.ValidatorTest.DefaultType
  alias Formex.ValidatorTest.CustomType
  alias Formex.TestModel.Article

  test "translate_error from config" do
    params = %{"title" => ""}
    form = create_form(DefaultType, %Article{}, params)

    {:error, form} = handle_form(form)

    assert form.errors == [title: ["This field is required"]]
  end

  test "translate_error from type" do
    params = %{"title" => ""}
    form = create_form(CustomType, %Article{}, params)

    {:error, form} = handle_form(form)

    assert form.errors == [title: ["custom error"]]
  end

end
