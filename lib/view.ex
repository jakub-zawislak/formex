defmodule Formex.View do
  use Phoenix.HTML
  alias Formex.Form

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

  """

  @doc """
  Works similar to `Phoenix.HTML.Form.form_for/4`

  In callback first argument is `t:Formex.Form.t/0` instead of `t:Phoenix.HTML.Form.t/0`.
  This argument contains a `t:Phoenix.HTML.Form.t/0` under `:phoenix_form` key
  """
  @spec formex_form_for(Form.t, String.t, Keyword.t (Formex.t -> Phoenix.HTML.unsafe))
                   :: Phoenix.HTML.safe
  def formex_form_for(form, action, options \\ [], fun) do
    Phoenix.HTML.Form.form_for(form.changeset, action, options, fn f ->
      form
      |> Map.put(:phoenix_form, f)
      |> fun.()
    end)
  end

  @doc """
  Generates all rows at once
  """
  def formex_rows(form) do
     Enum.map(form.fields, fn field ->
       formex_row(form, field.name)
     end)
  end


  @doc """
  Generates all rows at once
  """
  def formex_rows_horizontal(form) do
     Enum.map(form.fields, fn field ->
       formex_row_horizontal(form, field.name)
     end)
  end

  #

  @doc """
  Generates a row with Bootstraps's `.form-group` class. Example of use:

      <%= formex_row f, :title %>
      <%= formex_row f, :content %>
      <%= formex_row f, :category_id %>
  """
  @spec formex_row(Form.t, Atom.t) :: Phoenix.HTML.safe
  def formex_row(form, field_name) do

    field       = get_field(form, field_name)
    field_html  = generate_field_html(form, field)
    label_html  = generate_label_html(form, field)

    field_html = attach_addon(field_html, field)

    tags = [label_html, field_html]
    |> attach_error(form, field)

    wrapper_class = ["form-group"]
    |> attach_error_class(form, field)
    |> attach_required_class(field)

    content_tag(:div, tags, class: Enum.join(wrapper_class, " "))

  end

  @doc """
  Generates a row with Bootstraps's `.form-group` class. Should be used with `.form-horizontal` class.

      <div class="form-horizontal">
        <%= formex_row_horizontal f, :title %>
        <%= formex_row_horizontal f, :content %>
        <%= formex_row_horizontal f, :category_id %>
      </div>
  """
  @spec formex_row_horizontal(Form.t, Atom.t) :: Phoenix.HTML.safe
  def formex_row_horizontal(form, field_name) do

    field       = get_field(form, field_name)
    field_html  = generate_field_html(form, field)
    label_html  = generate_label_html(form, field, "col-sm-2")

    field_html = attach_addon(field_html, field)

    tags = [field_html]
    |> attach_error(form, field)

    wrapper_class = ["form-group"]
    |> attach_error_class(form, field)
    |> attach_required_class(field)

    column = content_tag(:div, tags, class: "col-sm-10")

    content_tag(:div, [label_html, column], class: Enum.join(wrapper_class, " "))

  end

  #

  @spec get_field(Form.t, Atom.t) :: Formex.Field.t
  defp get_field(form, field_name) do
     Enum.find(form.fields, fn field ->
       field.name == field_name
     end)
  end

  @spec generate_field_html(Form.t, Formex.Field.t) :: any
  defp generate_field_html(form, field) do

    type = field.type
    opts = field.opts
    data = field.data
    phoenix_opts = if opts[:phoenix_opts], do: opts[:phoenix_opts], else: []

    class = if opts[:class], do: opts[:class], else: ""

    args = [form.phoenix_form, field.name]
    args = args ++ cond do
      Enum.member? [:select, :multiple_select], type ->
        [data[:options], Keyword.merge([class: class<>" form-control"], phoenix_opts) ]

      Enum.member? [:checkbox], type ->
        [Keyword.merge([class: class], phoenix_opts) ]

      Enum.member? [:file_input], type ->
        [Keyword.merge([class: class], phoenix_opts) ]

      true ->
        [Keyword.merge([class: class<>" form-control"], phoenix_opts) ]
    end

    input = apply(Phoenix.HTML.Form, type, args)

    cond do
      Enum.member? [:checkbox], type ->
        content_tag(:div, [
          content_tag(:label, [
            input
            ])
          ], class: "checkbox")

      true ->
        input
    end
  end

  @spec generate_label_html(Form.t, Formex.Field.t, String.t) :: Phoenix.HTML.safe
  defp generate_label_html(form, field, class \\ "") do
    Phoenix.HTML.Form.label(
      form.phoenix_form,
      field.name,
      field.label,
      class: "control-label "<>class
    )
  end


  defp generate_error_field(form, field) do
    text = Application.get_env(:formex, :translate_error).(form.phoenix_form.errors[field.name])
    content_tag(:span, text, class: "help-block")
  end

  #

  defp attach_addon(field_html, field) do
    if field.opts[:addon] do
      addon = content_tag(:div, field.opts[:addon], class: "input-group-addon")
      content_tag(:div, [field_html, addon], class: "input-group" )
    else
      field_html
    end
  end

  defp attach_error(tags, form, field) do
    if form.phoenix_form.errors[field.name] do
      tags ++ [generate_error_field(form, field)]
    else
      tags
    end
  end

  defp attach_error_class(wrapper_class, form, field) do
    if form.phoenix_form.errors[field.name] do
      wrapper_class ++ ["has-error"]
    else
      wrapper_class
    end
  end

  defp attach_required_class(wrapper_class, field) do
    if field.required do
      wrapper_class ++ ["required"]
    else
      wrapper_class
    end
  end

end
