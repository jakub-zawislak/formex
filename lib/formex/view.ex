defmodule Formex.View do
  use Phoenix.HTML
  alias Formex.Form
  alias Formex.Field
  alias Formex.FormCollection
  alias Formex.FormNested
  alias Formex.Button

  @moduledoc """
  Helper functions for templating.

  Example of use:

      <%= formex_form_for @form, @action, fn f -> %>
        <%= if @form.changeset.action do %>
          <div class="alert alert-danger">
            <p>Oops, something went wrong! Please check the errors below.</p>
          </div>
        <% end %>

        <%= formex_rows f %>

        <div class="form-group">
          <%= submit "Submit", class: "btn btn-primary" %>
        </div>
      <% end %>

  ## Changing a form template

    You can change the template globally or in the specific form/field.

    * config
      ```
      config :formex,
        template: Formex.Template.BootstrapHorizontal
        template_options: [ # options used by this template
          left_column: "col-xs-2",
          right_column: "col-xs-10"
        ]
      ```

    * `formex_form_for/4`:
      ```
      <%= formex_form_for @form, @action, [
          class: "form-horizontal",
          template: Formex.Template.BootstrapHorizontal
        ], fn f -> %>
        ...
      <% end %>
      ```

    * `formex_rows/2`:
      ```
      <%= formex_rows f, template: Formex.Template.BootstrapHorizontal %>
      ```

    * `formex_row/3`:
      ```
      <%= formex_row f, :name, template: Formex.Template.BootstrapHorizontal %>
      ```
  """

  defmacro __using__([]) do
    quote do
      import Formex.View
      import Formex.View.Nested
      import Formex.View.Collection
    end
  end

  @doc """
  Works similar to a `Phoenix.HTML.Form.form_for/4`

  In the callback function the first argument is `t:Formex.Form.t/0` instead of a
  `t:Phoenix.HTML.Form.t/0`.
  This argument contains the `t:Phoenix.HTML.Form.t/0` under a `:phoenix_form` key

  ## Options

    * `template` - a form template that implements `Formex.Template`, for example:
      `Formex.Template.BootstrapHorizontal`
    * `template_options` - additional options, supported by the template

  """
  @spec formex_form_for(form :: Form.t, action :: String.t, options :: Keyword.t,
                        fun :: (Formex.t -> Phoenix.HTML.unsafe)) :: Phoenix.HTML.safe
  def formex_form_for(form, action, options \\ [], fun) do

    phoenix_options = options
    |> Keyword.delete(:template)
    |> Keyword.delete(:template_options)

    Phoenix.HTML.Form.form_for(form.changeset, action, phoenix_options, fn f ->
      form
      |> Map.put(:phoenix_form, f)
      |> Map.put(:template, options[:template])
      |> Map.put(:template_options, options[:template_options])
      |> fun.()
    end)
  end

  @doc """
  Generates all `formex_row/2`s at once

  ## Options

    * `template` - a form template that implements `Formex.Template`, for example:
      `Formex.Template.BootstrapHorizontal`
    * `template_options` - additional options, supported by the template
  """
  @spec formex_rows(Form.t, Keyword.t) :: Phoenix.HTML.safe
  def formex_rows(form, options \\ []) do
    Enum.map(form.items, fn item ->
      formex_row(form, item.name, options)
    end)
  end

  @doc """
  Generates a row

  Example of use:

      <%= formex_row f, :title %>
      <%= formex_row f, :content %>
      <%= formex_row f, :category_id %>

  ## Options

    * `template` - a form template that implements `Formex.Template`, for example:
      `Formex.Template.BootstrapHorizontal`
    * `template_options` - additional options, supported by the template
  """
  @spec formex_row(Form.t, Atom.t, Keyword.t) :: Phoenix.HTML.safe
  def formex_row(form, item_name, options \\ []) do

    item             = Enum.find(form.items, &(&1.name == item_name))
    template         = get_template(form, options)
    template_options = get_template_options(form, options)

    if !item do
      throw("Key :"<>to_string(item_name)<>" not found in form "<>to_string(form.type))
    end

    case item do
      %Field{} ->
        template.generate_row(form, item, template_options)
      %Button{} ->
        template.generate_row(form, item, template_options)
      %FormNested{} ->
        Formex.View.Nested.formex_nested(form, item_name, options)
      %FormCollection{} ->
        Formex.View.Collection.formex_collection(form, item_name, options)
    end
  end

  def get_template(form, row_options) do
    row_options[:template]
      || form.template
      || Application.get_env(:formex, :template)
      || Formex.Template.BootstrapVertical
  end

  def get_template_options(form, row_options) do
    []
    |> Keyword.merge(Application.get_env(:formex, :template_options) || [])
    |> Keyword.merge(form.template_options || [])
    |> Keyword.merge(row_options[:template_options] || [])
  end

end

defmodule Formex.View.Nested do
  import Formex.View

  def formex_nested(form, item_name) do
    formex_nested(form, item_name, [], nil)
  end

  def formex_nested(form, item_name, fun) when is_function(fun) do
    formex_nested(form, item_name, [], fun)
  end

  def formex_nested(form, item_name, options) when is_list(options) do
    formex_nested(form, item_name, options, nil)
  end

  def formex_nested(form, item_name, options \\ [], fun) do
    item             = Enum.find(form.items, &(&1.name == item_name))
    template         = Formex.View.get_template(form, options)
    template_options = Formex.View.get_template_options(form, options)

    if !item do
      throw("Key :"<>to_string(item_name)<>" not found in form "<>to_string(form.type))
    end

    fun = if !fun, do: &(formex_rows(&1)), else: fun

    Phoenix.HTML.Form.inputs_for(form.phoenix_form, item.name, fn f ->
      item.form
      |> Map.put(:phoenix_form, f)
      |> Map.put(:template, template)
      |> Map.put(:template_options, template_options)
      |> fun.()
    end)
  end
end

defmodule Formex.View.Collection do
  use Phoenix.HTML
  import Formex.View
  alias __MODULE__
  alias Formex.Utils.Counter

  defstruct [:form, :item, :template, :template_options, :fun_item]
  @type t :: %Collection{}

  def formex_collection(form, item_name) do
    formex_collection(form, item_name, [])
  end

  def formex_collection(form, item_name, options) when is_list(options) do
    formex_collection(form, item_name, options, &get_default_fun/1, &get_default_fun_item/1)
  end

  def formex_collection(form, item_name, fun) when is_function(fun) do
    formex_collection(form, item_name, [], fun, &get_default_fun_item/1)
  end

  def formex_collection(form, item_name, options, fun) when is_list(options) and is_function(fun) do
    formex_collection(form, item_name, options, fun, &get_default_fun_item/1)
  end

  def formex_collection(form, item_name, fun, fun_item) when is_function(fun) do
    formex_collection(form, item_name, [], fun, fun_item)
  end

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
        data: [prototype: prototype |> elem(1) |> to_string]
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
    {:ok, pid} = Counter.start_link # does anyone has a better idea?

    form = collection.form
    item = collection.item
    template = collection.template
    template_options = collection.template_options

    html = Phoenix.HTML.Form.inputs_for(form.phoenix_form, item.name, fn f ->
      subform = item.forms
      |> Enum.at(Counter.increment(pid))
      |> Map.get(:form)
      |> Map.put(:phoenix_form, f)
      |> Map.put(:template, template)
      |> Map.put(:template_options, template_options)

      html = collection.fun_item.(subform)

      delete = Phoenix.HTML.Form.checkbox f, :formex_delete,
        class: "formex-collection-item-remove-checkbox",
        style: "display: none;"

      content_tag(:div, [
        html,
        delete
      ], class: "formex-collection-item")
    end)

    Counter.reset(pid)

    content_tag(:div, html, class: "formex-collection-items")
  end

  def formex_collection_add(form_collection, label \\ "Add", class \\ "") do
    button = Formex.Button.create_button(:button, :add, label: label, phoenix_opts: [
      class: "formex-collection-add "<>class
    ])

    template_options = form_collection.template_options
    template = form_collection.template
    form = form_collection.form

    template.generate_row(form, button, template_options)
  end

  def formex_collection_remove(label \\ {:safe, "&times;"}, confirm \\ "Are you sure?") do
    content_tag(:a, [
      label
    ], href: "#", class: "formex-collection-item-remove", "data-confirm": confirm)
  end

  defp generate_collection_prototype(form, item_name, item, fun_item, options) do
    struct = form.model
    |> struct
    |> Map.put(item_name, [struct(item.model)])

    prot_form = Formex.Builder.create_form(form.type, struct)

    options = Keyword.put(options, :without_prototype, true)

    {:safe, prot_html} = formex_form_for(prot_form, "", fn f ->
      formex_collection(f, item_name, options, fn collection ->
        formex_collection_items(collection)
      end, fun_item)
    end)

    {:safe, Enum.at(prot_html, 1)}
  end
end
