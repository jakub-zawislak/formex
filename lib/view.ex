defmodule Formex.View do
  use Phoenix.HTML

  @spec formex_for(Formex.Form.t, String.t, Keyword.t (t::any -> Phoenix.HTML.unsafe))
                   :: Phoenix.HTML.safe
  def formex_for(form, action, options \\ [], fun) do

    Phoenix.HTML.Form.form_for(form.changeset, action, options, fn f ->
      form
      |> Map.put(:phoenix_form, f)
      |> fun.()
    end)

  end

  def generate_fields(form) do
     Enum.map(form.fields, fn field ->
       form_row(form, field.name)
     end)
  end

  def generate_fields_horizontal(form) do
     Enum.map(form.fields, fn field ->
       form_row_horizontal(form, field.name)
     end)
  end

  #

  @spec form_row(Formex.Form.t, Atom.t) :: Phoenix.HTML.safe
  def form_row(form, field_name) do

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

  @spec form_row_horizontal(Formex.Form.t, Atom.t) :: Phoenix.HTML.safe
  def form_row_horizontal(form, field_name) do

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

  @spec get_field(Formex.Form.t, Atom.t) :: Formex.Field.t
  defp get_field(form, field_name) do
     Enum.find(form.fields, fn field ->
       field.name == field_name
     end)
  end

  @spec generate_field_html(Formex.Form.t, Formex.Field.t) :: any
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

  @spec generate_label_html(Formex.Form.t, Formex.Field.t, String.t) :: Phoenix.HTML.safe
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
