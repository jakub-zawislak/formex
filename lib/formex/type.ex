defmodule Formex.Type do

  @moduledoc """
  In order to create a form, you need to create the Type file. It's similar to
  [Symfony's](https://symfony.com/doc/current/forms.html#creating-form-classes)
  way of creating forms.

  Example:

  ```
  defmodule App.ArticleType do
    use Formex.Type
    alias Formex.Ecto.CustomField.SelectAssoc

    def build_form(form) do
      form
      |> add(:title, :text_input, label: "Title")
      |> add(:content, :textarea, label: "Content", phoenix_opts: [
        rows: 4
      ])
      |> add(:hidden, :checkbox, label: "Is hidden", required: false)
      |> add(:category_id, :select, label: "Category", phoenix_opts: [
        prompt: "Select a category"
      ], choices: [
        "Category A": 1,
        "Category B": 2
      ])
      |> add(:save, :submit, label: if(form.struct.id, do: "Edit", else: "Add"), phoenix_opts: [
        class: "btn-primary"
      ])
    end
  end
  ```

  ## Nested forms

  We have models `User`, and `UserInfo`. The `UserInfo` contains extra information that we don't
  want, for some reason, store in the `User` model.

  ```
  defmodule App.User do
    defstruct [:first_name, :last_name, user_info: %App.UserInfo{}]
  end
  ```

  ```
  defmodule App.UserInfo do
    defstruct [:section, :organisation_cell]
  end
  ```

  Our form will consist of two modules:

  `user_type.ex`
  ```
  defmodule App.UserType do
    use Formex.Type

    def build_form(form) do
      form
      |> add(:first_name, :text_input)
      |> add(:last_name, :text_input)
      |> add(:user_info, App.UserInfoType, struct_module: App.UserInfo)
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
      <%= formex_nested f, :user_info, fn subform -> %>
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
  defmodule App.User do
    defstruct [:first_name, :last_name, user_addresses: []]
  end
  ```

  ```
  defmodule App.UserAddress do
    defstruct [:id, :street, :city, :formex_id, :formex_delete]
  end
  ```

  Keys `:id`, `:formex_id` and `:formex_delete` are important in collection child.

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
      |> add(:user_addresses, App.UserAddressType, struct_module: App.UserAddress)
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
        fn collection -> %>
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
      collection, collection_item %>
      ```

  For more info about rendering see `Formex.View.Collection.formex_collection/5`

  Result with some additional HTML and CSS:

  <img src="http://i.imgur.com/OZeW87P.png" width="724px">
  """

  defmacro __using__([]) do
    quote do
      @behaviour Formex.Type
      import Formex.Type

      # def validate_whole_struct?, do: false

      def validator, do: nil

      defoverridable [validator: 0]
      # defoverridable [validate_whole_struct?: 0, validator: 0]
    end
  end

  def add(form, name) do
    add(form, name, :text_input, [])
  end

  def add(form, name, opts) when is_list(opts) do
    add(form, name, :text_input, opts)
  end

  def add(form, name, type_or_module) when not is_list(type_or_module) do
    add(form, name, type_or_module, [])
  end

  @doc """
  Adds a form item to the form. May be a field, custom field, button, or subform.

  `type_or_module` is `:text_input` by default.

  Behaviour depends on `type_or_module` argument:
    * if it's a module and
      * implements `Formex.CustomField`, the `c:Formex.CustomField.create_field/3` is called
      * implements `Formex.Type`, the `Formex.Form.register/4` is called (it's for
        nested forms and collections of forms)
    * if it's `:submit` or `:reset`, the `Formex.Button.create_button/3` is called
    * otherwise, the `Formex.Field.create_field/4` is called.
  """
  @spec add(form :: Form.t, name :: Atom.t, type_or_module :: Atom.t, opts :: Map.t) :: Form.t
  def add(form, name, type_or_module, opts) do

    item = if Formex.Utils.module?(type_or_module) do
      if Formex.Utils.implements?(type_or_module, Formex.CustomField) do
        type_or_module.create_field(form, name, opts)
      else
        Formex.Form.start_creating(form, type_or_module, name, opts)
      end
    else
      if Enum.member?([:submit, :reset], type_or_module) do
        Formex.Button.create_button(type_or_module, name, opts)
      else
        Formex.Field.create_field(type_or_module, name, opts)
      end
    end

    Formex.Form.put_item(form, item)
  end

  @doc """
  In this callback you have to add fields to the form.
  """
  @callback build_form(form :: Formex.Form.t) :: Formex.Form.t

  # @doc """
  # The Vex validator has a `Vex.Struct.validates/2` that is used to define validation inside
  # a struct's module. `Formex.Vex` can use that validation in addition to a validation set in a form
  # type. Because it is not always a desired behaviour, you can control it in this callback.

  # Defaults to `false`.
  # """
  # @callback validate_whole_struct?() :: boolean

end
