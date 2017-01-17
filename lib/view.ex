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

  @spec form_row(Formex.Form.t, Atom.t, Map.t) :: Phoenix.HTML.safe
  def form_row(form, field_name, options \\ []) do

    field       = get_field(form, field_name)
    form_field  = generate_form_field(form, field, options)
    form_label  = generate_form_label(form, field)

    form_field = attach_addon(form_field, options)

    tags = [form_label, form_field]
      |> attach_error(form, field)

    wrapper_class = ["form-group"]
      |> attach_error_class(form, field)

    content_tag(:div, tags, class: Enum.join(wrapper_class, " "))

  end

  @spec form_row_horizontal(Formex.Form.t, Atom.t, Map.t) :: Phoenix.HTML.safe
  def form_row_horizontal(form, field_name, options \\ []) do

    field       = get_field(form, field_name)
    form_field  = generate_form_field(form, field, options)
    form_label  = generate_form_label(form, field, "col-sm-2")

    form_field = attach_addon(form_field, options)

    tags = [form_field]
      |> attach_error(form, field)

    wrapper_class = ["form-group"]
      |> attach_error_class(form, field)

    column = content_tag(:div, tags, class: "col-sm-10")

    content_tag(:div, [form_label, column], class: Enum.join(wrapper_class, " "))

  end

  #

  @spec get_field(Formex.Form.t, Atom.t) :: Formex.Field.t
  defp get_field(form, field_name) do
     Enum.find(form.fields, fn field ->
       field.name == field_name
     end)
  end

  @spec generate_form_field(Formex.Form.t, Formex.Field.t, Map.t) :: any
  defp generate_form_field(form, field, options) do

    type = field.type
    field_options = if options[:field_options], do: options[:field_options], else: []

    class = if field_options[:class_add], do: field_options[:class_add], else: ""

    args = [form.phoenix_form, field.name]
    args = args ++ cond do
      Enum.member? [:select, :multiple_select], type ->
        [options[:options], Keyword.merge([class: class<>" form-control"], field_options) ]

      Enum.member? [:checkbox], type ->
        [Keyword.merge([class: class], field_options) ] # dorobić checkboxowy stuff

      Enum.member? [:file_input], type ->
        [Keyword.merge([class: class], field_options) ]

      true ->
        [Keyword.merge([class: class<>" form-control"], field_options) ]
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

  @spec generate_form_field(Formex.Form.t, Formex.Field.t, String.t) :: Phoenix.HTML.safe
  defp generate_form_label(form, field, class \\ "") do
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

  defp attach_addon(form_field, options) do
    if options[:addon] do
      addon = content_tag(:div, options[:addon], class: "input-group-addon")
      content_tag(:div, [form_field, addon], class: "input-group" )
    else
      form_field
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
      ["has-error" | wrapper_class]
    else
      wrapper_class
    end
  end

end
