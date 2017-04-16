defmodule Formex.Collection.OneToMany.UserAddressType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:street, :text_input, label: "Street")
    |> add(:city, :text_input, label: "City")
    |> add(:postal_code, :text_input, label: "Postal code")
  end
end

defmodule Formex.Collection.OneToMany.UserAccountType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:number, :text_input)
  end
end

defmodule Formex.Collection.OneToMany.UserType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Imię")
    |> add(:last_name, :text_input, label: "Nazwisko")
    |> add(:user_addresses, Formex.Collection.OneToMany.UserAddressType, required: false)
  end
end

defmodule Formex.Collection.OneToMany.UserFilterType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:user_accounts, Formex.Collection.OneToMany.UserAccountType, 
      required: false, delete_field: :removed, filter: fn item ->
      !item.removed
    end)
  end
end

defmodule Formex.Collection.OneToMany.UserRequiredType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Imię")
    |> add(:last_name, :text_input, label: "Nazwisko")
    |> add(:user_addresses, Formex.Collection.OneToMany.UserAddressType)
  end
end

defmodule Formex.Collection.OneToManyTest do
  use Formex.CollectionCase
  use Formex.Controller
  alias Formex.Collection.OneToMany.UserType
  alias Formex.Collection.OneToMany.UserRequiredType
  alias Formex.Collection.OneToMany.UserFilterType

  test "view" do
    insert_users()

    form = create_form(UserType, %User{})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/Imię/)
    assert String.match?(form_str, ~r/Street/)
  end

  test "insert user and user_address" do
    params      = %{"first_name" => "a", "last_name" => "a"}
    form        = create_form(UserRequiredType, %User{}, params)
    {:error, _} = insert_form_data(form)

    params      = %{"first_name" => "a", "last_name" => "a"}
    form        = create_form(UserType, %User{}, params)
    {:ok,    _} = insert_form_data(form)

    params      = %{"first_name" => "a", "last_name" => "a", "user_addresses" => %{
      "0" => %{"street" => ""}
    }}
    form        = create_form(UserRequiredType, %User{}, params)
    {:error, _} = insert_form_data(form)

    params      = %{"first_name" => "a", "last_name" => "a", "user_addresses" => %{
      "0" => %{"street" => "s", "postal_code" => "p", "city" => "c"}
    }}
    form        = create_form(UserRequiredType, %User{}, params)
    {:ok, user} = insert_form_data(form)

    assert Enum.at(user.user_addresses, 0).city == "c"
  end

  test "edit user and user_address" do
    insert_users()

    user = get_user(0)

    params      = %{"user_addresses" => %{
      "0" => %{"street" => ""}
    }}
    form        = create_form(UserRequiredType, user, params)
    {:error, _} = update_form_data(form)

    params      = %{"user_addresses" => %{
      "0" => %{"street" => "s0", "postal_code" => "p0", "city" => "c0"}
    }}
    form        = create_form(UserRequiredType, user, params)
    {:ok, user} = update_form_data(form)

    params      = %{"user_addresses" => %{
      "0" => %{"id" => Enum.at(user.user_addresses, 0).id |> Integer.to_string,
        "street" => "s0new", "postal_code" => "p0new", "city" => "c0new"},
      "1" => %{"formex_id" => "1",
        "street" => "s1", "postal_code" => "p1", "city" => "c1"},
      "2" => %{"formex_id" => "2",
        "street" => "s2", "postal_code" => "p2", "city" => "c2"}
    }}
    user        = get_user(0) # download it again, we want unloaded user_address
    form        = create_form(UserRequiredType, user, params)
    {:ok, user} = update_form_data(form)

    assert Enum.at(user.user_addresses, 0).city == "c0new"
    assert Enum.at(user.user_addresses, 1).city == "c1"
    assert Enum.at(user.user_addresses, 2).city == "c2"
  end

  test "remove user_address" do
    insert_users()

    user = get_user(1)

    params      = %{"user_addresses" => %{
      "0" => %{"id" => Enum.at(user.user_addresses, 0).id |> Integer.to_string,
        "formex_delete" => "true"},
      "1" => %{"id" => Enum.at(user.user_addresses, 1).id |> Integer.to_string}
    }}
    form        = create_form(UserRequiredType, user, params)
    {:ok, _} = update_form_data(form)

    user = get_user(1)

    assert Enum.at(user.user_addresses, 0).city == "Olsztyn"
  end

  test "filter accounts" do
    insert_users()

    user = get_user(1)

    params = %{"user_accounts" => %{
      "0" => %{"id" => Enum.at(user.user_accounts, 0).id |> Integer.to_string},
      "1" => %{"id" => Enum.at(user.user_accounts, 1).id |> Integer.to_string,
        "removed" => "true"},
      "2" => %{"id" => Enum.at(user.user_accounts, 2).id |> Integer.to_string}
    }}
    form = create_form(UserFilterType, user, params)
    {:ok, _} = update_form_data(form)

    user = get_user(1)

    assert Enum.at(user.user_accounts, 1).removed == true

    # 

    form = create_form(UserFilterType, user)
    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/user\[user_accounts\]\[0\]\[removed\]/)
    assert !String.match?(form_str, ~r/user\[user_accounts\]\[1\]\[removed\]/)
    assert String.match?(form_str, ~r/user\[user_accounts\]\[2\]\[removed\]/)
  end
end
