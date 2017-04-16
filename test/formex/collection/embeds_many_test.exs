defmodule Formex.Collection.EmbedsMany.UserSchoolType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:name, :text_input, label: "School name")
  end
end

defmodule Formex.Collection.EmbedsMany.UserType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Imię")
    |> add(:last_name, :text_input, label: "Nazwisko")
    |> add(:schools, Formex.Collection.EmbedsMany.UserSchoolType, required: false)
  end
end

defmodule Formex.Collection.EmbedsMany.UserRequiredType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Imię")
    |> add(:last_name, :text_input, label: "Nazwisko")
    |> add(:schools, Formex.Collection.EmbedsMany.UserSchoolType)
  end
end

defmodule Formex.Collection.EmbedsManyTest do
  use Formex.CollectionCase
  use Formex.Controller
  alias Formex.Collection.EmbedsMany.UserType
  alias Formex.Collection.EmbedsMany.UserRequiredType

  test "view" do
    insert_users()

    form = create_form(UserType, %User{})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/Imię/)
    assert String.match?(form_str, ~r/School name/)
  end

  test "insert user and school" do
    params      = %{"first_name" => "a", "last_name" => "a"}
    form        = create_form(UserRequiredType, %User{}, params)
    {:error, _} = insert_form_data(form)

    params      = %{"first_name" => "a", "last_name" => "a"}
    form        = create_form(UserType, %User{}, params)
    {:ok,    _} = insert_form_data(form)

    params      = %{"first_name" => "a", "last_name" => "a", "schools" => %{
      "0" => %{"name" => "", "formex-id" => "some-id"}
    }}
    form        = create_form(UserRequiredType, %User{}, params)
    {:error, _} = insert_form_data(form)

    params      = %{"first_name" => "a", "last_name" => "a", "schools" => %{
      "0" => %{"name" => "s", "formex-id" => "some-id"}
    }}
    form        = create_form(UserRequiredType, %User{}, params)
    {:ok, user} = insert_form_data(form)

    assert Enum.at(user.schools, 0).name == "s"
  end

  test "edit user and school" do
    insert_users()

    user = get_user(0)

    params      = %{"schools" => %{
      "0" => %{"name" => ""}
    }}
    form        = create_form(UserRequiredType, user, params)
    {:error, _} = update_form_data(form)

    params      = %{"schools" => %{
      "0" => %{"name" => "name0"}
    }}
    form        = create_form(UserRequiredType, user, params)
    {:ok, user} = update_form_data(form)

    params      = %{"schools" => %{
      "0" => %{"id" => Enum.at(user.schools, 0).id, "name" => "name0new"},
      "1" => %{"formex_id" => "1", "name" => "name1"},
      "2" => %{"formex_id" => "2", "name" => "name2"}
    }}
    user        = get_user(0) # download it again, we want unloaded school
    form        = create_form(UserRequiredType, user, params)
    {:ok, user} = update_form_data(form)

    assert Enum.at(user.schools, 0).name == "name0new"
    assert Enum.at(user.schools, 1).name == "name1"
    assert Enum.at(user.schools, 2).name == "name2"
  end

  test "remove school" do
    insert_users()

    user = get_user(1)

    params      = %{"schools" => %{
      "0" => %{"id" => Enum.at(user.schools, 0).id,
        "formex_delete" => "true"},
      "1" => %{"id" => Enum.at(user.schools, 1).id}
    }}
    form        = create_form(UserRequiredType, user, params)
    {:ok, _} = update_form_data(form)

    user = get_user(1)

    assert Enum.at(user.schools, 0).name == "Liceum"
  end
end
