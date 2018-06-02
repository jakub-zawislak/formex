defmodule Formex.Nested.OneToOne.UserInfoType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:section, :text_input, label: "Sekcja", validation: [:required])
  end
end

defmodule Formex.Nested.OneToOne.UserType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Imię", validation: [:required])
    |> add(:last_name, :text_input, label: "Nazwisko", validation: [:required])
    |> add(
      :user_info,
      Formex.Nested.OneToOne.UserInfoType,
      struct_module: Formex.TestModel.UserInfo
    )
  end
end

defmodule Formex.Nested.OneToOneTest do
  use Formex.NestedCase
  use Formex.Controller
  alias Formex.Nested.OneToOne.UserType

  test "view" do
    form = create_form(UserType, %User{})

    {:safe, form_html} =
      Formex.View.formex_form_for(form, "", fn f ->
        Formex.View.formex_rows(f)
      end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/Imię/)
    assert String.match?(form_str, ~r/Sekcja/)
  end

  test "basic test" do
    params = %{"first_name" => "a", "last_name" => "a"}
    form = create_form(UserType, %User{}, params)
    {:error, _} = handle_form(form)

    params = %{"first_name" => "a", "last_name" => "a", "user_info" => %{"section" => ""}}
    form = create_form(UserType, %User{}, params)
    {:error, _} = handle_form(form)

    params = %{"first_name" => "a", "last_name" => "a", "user_info" => %{"section" => "s"}}
    form = create_form(UserType, %User{}, params)
    {:ok, user} = handle_form(form)

    assert user.user_info.section == "s"

    params = %{"first_name" => "a", "last_name" => "a", "user_info" => %{"section" => "s"}}

    form =
      create_form(
        UserType,
        %User{
          first_name: "y",
          user_info: %UserInfo{section: "q"}
        },
        params
      )

    {:ok, user} = handle_form(form)

    assert user.user_info.section == "s"
  end
end
