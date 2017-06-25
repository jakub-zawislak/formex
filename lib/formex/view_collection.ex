defmodule Formex.View.Collection do
  use Phoenix.HTML
  import Formex.View
  alias __MODULE__
  alias Formex.Form
  alias Formex.FormCollection

  @moduledoc """
  Helper functions for templating collection of forms.

  See [Type docs](https://hexdocs.pm/formex/Formex.Type.html#module-collections-of-forms)
  for example of use.
  """

  defstruct [:form, :item, :template, :template_options, :fun_item]
  @type t :: %Collection{}

  @doc false
  def formex_collection(form, item_name) do
    formex_collection(form, item_name, [])
  end

  @doc false
  def formex_collection(form, item_name, options) when is_list(options) do
    formex_collection(form, item_name, options, &get_default_fun/1, &get_default_fun_item/1)
  end

  @doc false
  def formex_collection(form, item_name, fun) when is_function(fun) do
    formex_collection(form, item_name, [], fun, &get_default_fun_item/1)
  end

  @doc false
  def formex_collection(form, item_name, options, fun) when is_list(options) and is_function(fun) do
    formex_collection(form, item_name, options, fun, &get_default_fun_item/1)
  end

  @doc false
  def formex_collection(form, item_name, fun, fun_item) when is_function(fun) do
    formex_collection(form, item_name, [], fun, fun_item)
  end

  @doc """
  Generates a HTML for collection of forms

  ## Examples of use:

  * Standard
      ```
      <%= formex_collection f, :user_addresses %>
      ```
  * Set a form template for collection
      ```
      <div class="form-horizontal">
        <%= formex_collection f, :user_addresses, template: Formex.Template.BootstrapHorizontal %>
      </div>
      ```
  * Use your render function
      ```
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

  ## Generated HTML

  The `formex_collection` produces
  ```html
  <div class="formex-collection data-formex-prototype="..."></div>
  ```
  The `formex-prototype` is used by JS to generate new subforms.

  Content of `.formex-collection` is a result of a `fun` argument, which by default is:
  ```
  <%= formex_collection_items collection %>
  <%= formex_collection_add collection %>
  ```

  The `formex_collection_items` produces
  ```html
  <div class="formex-collection-items"></div>
  ```

  Content of `.formex-collection-items` is a result of a `fun_item` argument, which by default is:
  ```
  <%= formex_collection_remove %>
  <%= formex_rows subform %>
  ```

  The final result may look like this:
  ```html
  <div class="formex-collection" data-formex-prototype=" result of `fun_item` ">

    <div class="formex-collection-items">

      <input name="user[user_addresses][0][id]" type="hidden" value="1">
      <div class="formex-collection-item">
        <input name="user[user_addresses][0][formex_delete]" type="hidden" value="false">
        <a class="formex-collection-item-remove" data-formex-confirm="Are you sure?" href="#">×</a>
        subform inputs
      </div>

      <input name="user[user_addresses][1][id]" type="hidden" value="9">
      <div class="formex-collection-item">
      <input name="user[user_addresses][1][formex_delete]" type="hidden" value="false">
        <a class="formex-collection-item-remove" data-formex-confirm="Are you sure?" href="#">×</a>
        subform inputs
      </div>

    </div>

    <button class="formex-collection-add" type="button">Add</button>

  </div>
  ```

  """
  @spec formex_collection(Form.t, Atom.t, List.t, fun :: (t -> Phoenix.HTML.unsafe),
    fun_item :: (Formex.t -> Phoenix.HTML.unsafe)) :: Phoenix.HTML.safe
  def formex_collection(form, item_name, options, fun, fun_item) do
    item             = Enum.find(form.items, &(&1.name == item_name))
    template         = Formex.View.get_template(form, options)
    template_options = Formex.View.get_template_options(form, options)

    if !item do
      throw("Key :"<>to_string(item_name)<>" not found in form "<>to_string(form.type))
    end

    prototype = if !options[:without_prototype] do
      generate_collection_prototype(form, item_name, item, fun_item, options)
    end

    html = fun.(%Collection{
      form: form,
      item: item,
      template: template,
      template_options: template_options,
      fun_item: fun_item
    })

    if prototype do
      content_tag :div, html,
        class: "formex-collection",
        data: ["formex-prototype": prototype |> elem(1) |> to_string]
    else
      html
    end
  end

  defp get_default_fun(collection) do
    [
      formex_collection_items(collection),
      formex_collection_add(collection)
    ]
  end

  defp get_default_fun_item(subform) do
    [
      formex_collection_remove(),
      formex_rows(subform)
    ]
  end

  @spec formex_collection_items(t) :: Phoenix.HTML.safe
  def formex_collection_items(collection) do
    form = collection.form
    item = collection.item
    template = collection.template
    template_options = collection.template_options

    html = form.phoenix_form
    |> Phoenix.HTML.Form.inputs_for(item.name, [default: []], fn f ->
      fake_struct = %{id: f.params["id"], formex_id: f.params["formex_id"]}

      item
      |> FormCollection.get_subform_by_struct(fake_struct)
      |> case do
        nil -> ""
        nested_form ->
          subform = nested_form.form
          |> Map.put(:phoenix_form, f)
          |> Map.put(:template, template)
          |> Map.put(:template_options, template_options)

          html = collection.fun_item.(subform)

          style = if FormCollection.to_be_removed(item, nested_form) do
            "display: none;"
          else
            ""
          end

          if subform.struct.id do
            id_field = Phoenix.HTML.Form.hidden_input f, :id
            delete_field = Phoenix.HTML.Form.hidden_input f, item.delete_field,
              "data-formex-remove": ""

            content_tag(:div, [
              html,
              id_field,
              delete_field
            ], class: "formex-collection-item", style: style)
          else
            formex_id_field = Phoenix.HTML.Form.hidden_input f, :formex_id, "data-formex-id": ""

            content_tag(:div, [
              html,
              formex_id_field
            ], class: "formex-collection-item formex-collection-item-new", style: style)
          end
      end
    end)

    content_tag(:div, html, class: "formex-collection-items")
  end

  @spec formex_collection_add(t, String.t, String.t) :: Phoenix.HTML.safe
  def formex_collection_add(form_collection, label \\ "Add", class \\ "") do
    button = Formex.Button.create_button(:button, :add, label: label, phoenix_opts: [
      class: "formex-collection-add "<>class
    ])

    template_options = form_collection.template_options
    template = form_collection.template
    form = form_collection.form

    template.generate_row(form, button, template_options)
  end

  @spec formex_collection_remove(String.t, String.t) :: Phoenix.HTML.safe
  def formex_collection_remove(label \\ {:safe, "&times;"}, confirm \\ "Are you sure?") do
    content_tag(:a, [
      label
    ], href: "#", class: "formex-collection-item-remove", "data-formex-confirm": confirm)
  end

  defp generate_collection_prototype(form, item_name, item, fun_item, options) do
    substruct = item.struct_module
    |> struct

    struct = form.struct_module
    |> struct
    |> Map.put(item_name, [substruct])

    prot_form = Formex.Builder.create_form(form.type, struct, %{}, form.opts)

    options = Keyword.put(options, :without_prototype, true)

    {:safe, prot_html} = formex_form_for(prot_form, "", [as: form.phoenix_form.name], fn f ->
      formex_collection(f, item_name, options, fn collection ->
        formex_collection_items(collection)
      end, fun_item)
    end)

    {:safe, Enum.at(prot_html, 1)}
  end
end
