defmodule Formex.Embedded.Collection.UserAddressType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:street, :text_input, label: "Street")
    |> add(:city, :text_input, label: "City")
    |> add(:postal_code, :text_input, label: "Postal code")
  end
end

defmodule Formex.Embedded.Collection.UserType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Imię")
    |> add(:last_name, :text_input, label: "Nazwisko")
    |> add(:user_addresses, Formex.Embedded.Collection.UserAddressType, required: false)
  end
end

defmodule Formex.Embedded.CollectionTest do
  use Formex.EmbeddedCase
  use Formex.Controller
  alias Formex.Embedded.Collection.UserType

  test "view" do
    form = create_form(UserType, %User{first_name: "Bożątko"})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/Bożątko/)
    assert String.match?(form_str, ~r/Imię/)
    assert String.match?(form_str, ~r/Street/)
  end

  test "insert user and user_address" do
    params      = %{"first_name" => "a", "last_name" => "a"}
    form        = create_form(UserType, %User{}, params)
    {:ok,    _} = handle_form(form)

    params      = %{"first_name" => "a", "last_name" => "a", "user_addresses" => %{
      "0" => %{"street" => ""}
    }}
    form        = create_form(UserType, %User{}, params)
    {:error, _} = handle_form(form)

    params      = %{"first_name" => "a", "last_name" => "a", "user_addresses" => %{
      "0" => %{"street" => "s", "postal_code" => "p", "city" => "c"}
    }}
    form        = create_form(UserType, %User{}, params)
    {:ok, user} = handle_form(form)

    assert user.first_name == "a"
    assert Enum.at(user.user_addresses, 0).city == "c"
  end
end
