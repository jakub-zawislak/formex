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
        <%= if @form.submitted? do %>
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
  Works similar to a
  [Phoenix.HTML.Form](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#form_for/4)

  In the callback function the first argument is `t:Formex.Form.t/0` instead of a
  `t:Phoenix.HTML.Form.t/0`.
  This argument contains the `t:Phoenix.HTML.Form.t/0` under a `:phoenix_form` key

  ## Options
    In `options` argument you are passing together options for `Formex.View` and for `Phoenix.HTML`.

  ### Formex options

    * `template` - a form template that implements `Formex.Template`, for example:
      `Formex.Template.BootstrapHorizontal`
    * `template_options` - additional options, supported by the template

  ### Phoenix options

    Options not mentioned before will be passed to a
    [Phoenix.HTML.Form](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#form_for/4)
    function. Options below are already set by Formex and can be overriden.

    * `as` - form name, defaults to struct name
    * `method` - method, defaults to `:post`

  For rest of options, see
  [Phoenix.HTML.Form](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#form_for/4) docs.

  """
  @spec formex_form_for(
          form :: Form.t(),
          action :: String.t(),
          options :: Keyword.t(),
          fun :: (Formex.t() -> Phoenix.HTML.unsafe())
        ) :: Phoenix.HTML.safe()
  def formex_form_for(form, action, options \\ [], fun) do
    phoenix_options =
      options
      |> Keyword.delete(:template)
      |> Keyword.delete(:template_options)
      |> Keyword.put_new(:as, form_for_name(form))
      |> Keyword.put_new(:method, form.method || :post)

    fake_params =
      %{}
      |> Map.put(to_string(phoenix_options[:as]), form_to_params(form))

    fake_conn = %Plug.Conn{params: fake_params, method: "POST"}

    Phoenix.HTML.Form.form_for(fake_conn, action, phoenix_options, fn phx_form ->
      form
      |> Map.put(:phoenix_form, phx_form)
      |> Map.put(:template, options[:template])
      |> Map.put(:template_options, options[:template_options])
      |> fun.()
    end)
  end

  defp form_for_name(%{struct_module: module}) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
  end

  @spec form_to_params(form :: Form.t()) :: Map.t()
  defp form_to_params(form) do
    form.items
    |> Enum.map(fn item ->
      case item do
        %Field{} ->
          form_to_params_field(form, item)

        %FormNested{} ->
          form_to_params_nested(form, item)

        %FormCollection{} ->
          form_to_params_collection(form, item)

        _ ->
          false
      end
    end)
    |> Enum.filter(& &1)
    |> Enum.into(%{})
  end

  @spec form_to_params_field(form :: Form.t(), item :: Field.t()) :: Map.t()
  defp form_to_params_field(form, item) do
    val =
      if item.custom_value do
        value = Map.get(form.new_struct, item.struct_name)
        item.custom_value.(value)
      else
        Map.get(form.new_struct, item.struct_name)
      end

    new_val =
      case item.type do
        :multiple_select ->
          (val || [])
          |> Enum.map(fn subval ->
            subval
            |> case do
              substruct when is_map(substruct) ->
                substruct.id

              _ ->
                subval
            end
            |> to_string
          end)

        _ ->
          val
      end

    {to_string(item.name), new_val}
  end

  @spec form_to_params_nested(form :: Form.t(), item :: FormNested.t()) :: Map.t()
  defp form_to_params_nested(_form, item) do
    sub_params = form_to_params(item.form)
    sub_struct = item.form.new_struct

    sub_params =
      if Map.has_key?(sub_struct, :id) do
        sub_params
        |> Map.put("id", sub_struct.id |> to_string)
      else
        sub_params
      end

    {to_string(item.name), sub_params}
  end

  @spec form_to_params_collection(form :: Form.t(), item :: FormCollection.t()) :: Map.t()
  defp form_to_params_collection(_form, item) do
    new_val =
      item.forms
      |> Enum.count()
      |> (&Range.new(0, &1 - 1)).()
      |> Enum.zip(item.forms)
      |> Enum.map(fn {key, nested_form} ->
        sub_struct = nested_form.form.new_struct

        subparams =
          nested_form.form
          |> form_to_params()
          |> Map.put("id", sub_struct.id |> to_string)
          |> Map.put("formex_id", sub_struct.formex_id)
          |> Map.put(
            to_string(item.delete_field),
            sub_struct
            |> Map.get(item.delete_field)
            |> to_string
          )

        {key, subparams}
      end)
      |> Enum.into(%{})

    {to_string(item.name), new_val}
  end

  @doc """
  Generates all `formex_row/2`s at once

  ## Options

    * `template` - a form template that implements `Formex.Template`, for example:
      `Formex.Template.BootstrapHorizontal`
    * `template_options` - additional options, supported by the template
  """
  @spec formex_rows(Form.t(), Keyword.t()) :: Phoenix.HTML.safe()
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
  @spec formex_row(Form.t(), Atom.t(), Keyword.t()) :: Phoenix.HTML.safe()
  def formex_row(form, item_name, options \\ []) do
    item = get_item(form, item_name)
    template = get_template(form, options)
    template_options = get_template_options(form, options)

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

  @spec formex_input(Form.t(), Atom.t(), Keyword.t()) :: Phoenix.HTML.safe()
  def formex_input(form, item_name, options \\ []) do
    item = get_item(form, item_name)
    template = get_template(form, options)

    template.generate_input(form, item)
  end

  @spec formex_label(Form.t(), Atom.t(), Keyword.t()) :: Phoenix.HTML.safe()
  def formex_label(form, item_name, options \\ []) do
    item = get_item(form, item_name)
    template = get_template(form, options)
    class = (options[:class] && options[:class]) || ""

    template.generate_label(form, item, class)
  end

  def get_template(form, row_options) do
    row_options[:template] || form.template || Application.get_env(:formex, :template) ||
      Formex.Template.BootstrapVertical
  end

  def get_template_options(form, row_options) do
    []
    |> Keyword.merge(Application.get_env(:formex, :template_options) || [])
    |> Keyword.merge(form.template_options || [])
    |> Keyword.merge(row_options[:template_options] || [])
  end

  defp get_item(form, item_name) do
    item = Enum.find(form.items, &(&1.name == item_name))

    if !item do
      throw("Key :" <> to_string(item_name) <> " not found in form " <> to_string(form.type))
    end

    item
  end
end
