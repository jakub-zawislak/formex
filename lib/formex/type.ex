defmodule Formex.Type do

  @moduledoc """
  In order to create a form, you need to create the Type file. It's similar to
  [Symfony's](https://symfony.com/doc/current/forms.html#creating-form-classes)
  way of creating forms.

  Example:

  ```
  defmodule App.ArticleType do
    use Formex.Type
    alias Formex.CustomField.SelectAssoc

    def build_form(form) do
      form
      |> add(:title, :text_input, label: "Title")
      |> add(:content, :textarea, label: "Content", phoenix_opts: [
        rows: 4
      ])
      |> add(:hidden, :checkbox, label: "Is hidden", required: false)
      |> add(:category_id, SelectAssoc, label: "Category", phoenix_opts: [
        prompt: "Choose category"
      ])
      |> add(:save, :submit, label: if(form.struct.id, do: "Edit", else: "Add"), phoenix_opts: [
        class: "btn-primary"
      ])
    end

    # optional
    def changeset_after_create_callback(changeset) do
      # do an extra validation
      changeset
    end
  end
  ```

  ## Nested forms

  We have models `User`, and `UserInfo`. The `UserInfo` contains extra information that we don't
  want, for some reason, store in the `User` model.

  ```
  schema "users" do
    field       :first_name, :string
    field       :last_name, :string
    belongs_to  :user_info, App.UserInfo
  end
  ```

  ```
  schema "user_infos" do
    field   :section, :string
    field   :organisation_cell, :string
    has_one :user, App.User
  end
  ```

  Note: `belongs_to` can also be placed in `UserInfo` and so on, it doesn't matter in this example.

  Our form will consist of two modules:

  `user_type.ex`
  ```
  defmodule App.UserType do
    use Formex.Type

    def build_form(form) do
      form
      |> add(:first_name, :text_input)
      |> add(:last_name, :text_input)
      |> add(:user_info, App.UserInfoType)
    end
  end
  ```

  `user_info_type.ex`
  ```
  defmodule App.UserInfoType do
    use Formex.Type

    def build_form( form ) do
      form
      |> add(:section, :text_input)
      |> add(:organisation_cell, :text_input)
    end
  end
  ```

  Our form can be displayed in various ways:
  * Print whole form, with nested form, at once
      ```
      <%= formex_rows f %>
      ```
  * Standard
      ```
      <%= formex_row f, :first_name %>
      <%= formex_row f, :last_name %>
      <%= formex_nested f, :user_info %>
      ```
  * Set a form template for nested form
      ```
      <%= formex_row f, :first_name %>
      <%= formex_row f, :last_name %>
      <div class="form-horizontal">
        <%= formex_nested f, :user_info, template: Formex.Template.BootstrapHorizontal %>
      </div>
      ```
  * Use your render function
      ```
      <%= formex_row f, :first_name %>
      <%= formex_row f, :last_name %>
      <%= formex_nested f, :user_info, fun subform -> %>
        <%= formex_row subform, :section %>
        <%= formex_row subform, :organisation_cell %>
      <% end %>
      ```


  ## Collections of forms

  ### Installation

  To start using this functionality you have to include the JS library.

  `package.json`
  ```json
  "dependencies": {
    "formex": "file:deps/formex",
  }
  ```

  JavaScript
  ```javascript
  import {Collection} from 'formex'

  Collection.run(function() {
    // optional callback on collection change
  })
  ```

  ### Model

  We have models `User`, and `UserAddress`.

  ```
  schema "users" do
    field     :first_name, :string
    field     :last_name, :string
    has_many  :user_addresses, App.UserAddress
  end
  ```

  ```
  schema "user_addresses" do
    field       :street, :string
    field       :postal_code, :string
    field       :city, :string
    belongs_to  :user, App.User

    formex_collection_child() # important!
  end
  ```

  ### Form Type

  Our form will consist of two modules:

  `user_type.ex`
  ```
  defmodule App.UserType do
    use Formex.Type

    def build_form(form) do
      form
      |> add(:first_name, :text_input)
      |> add(:last_name, :text_input)
      |> add(:user_addresses, App.UserAddressType)
    end
  end
  ```

  `user_address_type.ex`
  ```
  defmodule App.UserAddressType do
    use Formex.Type

    def build_form( form ) do
      form
      |> add(:street, :text_input)
      |> add(:city, :text_input)
    end
  end
  ```

  ### Template

  Our collection can be displayed in various ways:
  * Print whole form, with collection, at once
      ```
      <%= formex_rows f %>
      ```
  * Standard
      ```
      <%= formex_row f, :first_name %>
      <%= formex_row f, :last_name %>
      <%= formex_collection f, :user_addresses %>
      ```
  * Set a form template for collection
      ```
      <%= formex_row f, :first_name %>
      <%= formex_row f, :last_name %>
      <div class="form-horizontal">
        <%= formex_collection f, :user_addresses, template: Formex.Template.BootstrapHorizontal %>
      </div>
      ```
  * Use your render function
      ```
      <%= formex_row f, :first_name %>
      <%= formex_row f, :last_name %>
      <%= formex_collection f, :user_addresses, [template: Formex.Template.BootstrapHorizontal],
        fun collection -> %>
        <div class="form-horizontal">
          <%= formex_collection_items collection %>
          <%= formex_collection_add collection, "Add" %>
        </div>
      <% end %>
      ```
  * You can also set a render function for collection item
      ```
      <%= formex_row f, :first_name %>
      <%= formex_row f, :last_name %>

      <% collection = fn collection -> %>
        <div class="form-horizontal">
          <%= formex_collection_items collection %>
          <%= formex_collection_add collection, "Add" %>
        </div>
      <% end %>

      <% collection_item = fn subform -> %>
        <%= formex_collection_remove {:safe, "&times;"}, "Are you sure you want to remove?" %>
        <%= formex_row subform, :street %>
        <%= formex_row subform, :city %>
      <% end %>

      <%= formex_collection f, :user_addresses, [template: Formex.Template.BootstrapHorizontal],
      collection, collection_item, end %>
      ```

  Result with some additional HTML and CSS:

  <img src="http://i.imgur.com/OZeW87P.png" width="724px">
  """

  defmacro __using__([]) do
    quote do
      @behaviour Formex.Type
      import Formex.Type

      def changeset_after_create_callback( changeset ) do
        changeset
      end

      defoverridable [changeset_after_create_callback: 1]
    end
  end

  # * an `*_to_many` assoc, the `Formex.Field.add_collection/4` is called

  @doc """
  Adds an form item to the form. May be a field, custom field, button, or subform.

  Behaviour depends on `type_or_module` argument:
    * if it's a module and
      * implements Formex.CustomField, the `c:Formex.CustomField.create_field/3` is called
      * implements Formex.Type, the `Formex.Form.create_subform/4` is called
    * if it's `:submit` or `:reset`, the `Formex.Button.create_button/3` is called
    * otherwise, the `Formex.Field.create_field/4` is called.
  """
  @spec add(form :: Form.t, name :: Atom.t, type_or_module :: Atom.t, opts :: Map.t) :: Form.t
  def add(form, name, type_or_module, opts \\ []) do

    {form, item} = if Formex.Utils.module?(type_or_module) do
      if Formex.Utils.implements?(type_or_module, Formex.CustomField) do
        {form, type_or_module.create_field(form, name, opts)}
      else
        Formex.Form.create_subform(form, type_or_module, name, opts)
      end
    else
      if Enum.member?([:submit, :reset], type_or_module) do
        {form, Formex.Button.create_button(type_or_module, name, opts)}
      else
        {form, Formex.Field.create_field(form, type_or_module, name, opts)}
      end
    end

    Formex.Form.put_item(form, item)
  end

  @doc """
  In this callback you have to add fields to the form.
  """
  @callback build_form(form :: Formex.Form.t) :: Formex.Form.t

  @doc """
  Callback that will be called after changeset creation. In this function you can
  for example add an extra validation to your changeset.
  """
  @callback changeset_after_create_callback(changeset :: Ecto.Changeset.t) :: Ecto.Changeset.t

end
