defmodule Formex.Select.NormalType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:title, :text_input, validation: [:required])
    |> add(:category_id, :select, choices: [
      "Category A": 1,
      "Category B": 2
    ], validation: [:required])
  end
end

defmodule Formex.Select.WithoutChoicesType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:title, :text_input, validation: [:required])
    |> add(:category_id, :select, without_choices: true)
    |> add(:user_id, :select, validation: [:required], without_choices: true,
      choice_label_provider: fn id ->
        %{
          "1" => "John",
          "2" => "Ahmed"
        }
        |> Map.get(id)
      end
    )
  end
end

defmodule Formex.Select.WithoutChoicesCollectionType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, validation: [:required])
    |> add(:user_addresses, Formex.Select.WithoutChoicesCollectionChildType,
      struct_module: Formex.TestModel.UserAddress
    )
  end
end

defmodule Formex.Select.WithoutChoicesCollectionChildType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:street, :text_input, validation: [:required])
    |> add(:country_id, :select, validation: [:required], without_choices: true,
      choice_label_provider: fn id ->
        %{
          "1" => "Poland",
          "2" => "Germany"
        }
        |> Map.get(id)
      end
    )
  end
end

defmodule Formex.Select do
  use Formex.TestCase
  use Formex.Controller
  use Formex.CollectionCase
  alias Formex.Select.NormalType
  alias Formex.Select.WithoutChoicesType
  alias Formex.Select.WithoutChoicesCollectionType
  alias Formex.TestModel.Article
  alias Formex.TestModel.User

  test "valid value" do
    params = %{"title" => "test", "category_id" => "1"}
    form = create_form(NormalType, %Article{}, params)

    {:ok, _} = handle_form(form)
  end

  test "invalid value" do
    params = %{"title" => "test", "category_id" => "3"}

    form = create_form(NormalType, %Article{}, params)
    {:error, form} = handle_form(form)

    assert form.errors[:category_id] == ["invalid value"]
  end

  test ":without_choices valid value" do
    params = %{"title" => "test", "category_id" => "", "user_id" => "1"}
    form = create_form(WithoutChoicesType, %Article{}, params)

    {:ok, _} = handle_form(form)
  end

  test ":without_choices invalid value" do
    params = %{"title" => "test", "category_id" => "", "user_id" => "3"}

    form = create_form(WithoutChoicesType, %Article{}, params)
    {:error, form} = handle_form(form)

    assert form.errors[:user_id] == ["invalid value"]
  end

  test ":without_choices loading label" do
    article = %Article{user_id: "1"}

    form = create_form(WithoutChoicesType, article)

    assert Formex.Form.find(form, :user_id).data[:choices] == [{"John", "1"}]

    #

    params = %{"title" => "", "category_id" => "", "user_id" => "2"}

    form = create_form(WithoutChoicesType, article, params)

    {:error, form} = handle_form(form)

    assert Formex.Form.find(form, :user_id).data[:choices] == [{"Ahmed", "2"}]
  end

  test ":without_choices in collections" do
    user = get_user(0)

    # loaded label

    form = create_form(WithoutChoicesCollectionType, user)

    address_nested = Formex.Form.find(form, :user_addresses).forms |> Enum.at(0)
    assert Formex.Form.find(address_nested.form, :country_id).data[:choices] == [{"Poland", "1"}]

    # loaded label after submit

    params = %{"first_name" => "", "user_addresses" => %{
      "0" => %{"id" => Enum.at(user.user_addresses, 0).id |> to_string, "country_id" => "2"}
    }}

    form = create_form(WithoutChoicesCollectionType, user, params)

    {:error, form} = handle_form(form)

    address_nested = Formex.Form.find(form, :user_addresses).forms |> Enum.at(0)
    assert Formex.Form.find(address_nested.form, :country_id).data[:choices] == [{"Germany", "2"}]

    # bad value

    params = %{"first_name" => "", "user_addresses" => %{
      "0" => %{"id" => Enum.at(user.user_addresses, 0).id |> to_string, "country_id" => "3"}
    }}

    form = create_form(WithoutChoicesCollectionType, user, params)
    {:error, form} = handle_form(form)

    collection_item_form = form
    |> Formex.Form.find(:user_addresses)
    |> Map.get(:forms)
    |> Enum.at(0)
    |> Map.get(:form)

    assert collection_item_form.errors[:country_id] == ["invalid value"]
  end

end
