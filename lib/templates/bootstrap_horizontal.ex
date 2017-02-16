defmodule Formex.Template.BootstrapHorizontal do
  use Formex.Template, :main
  import Formex.Template.Bootstrap

  def generate_row(form, field, template_options \\ []) do

    left_column   = Keyword.get(template_options, :left_column, "col-sm-2")
    right_column  = Keyword.get(template_options, :right_column, "col-sm-10")

    field_html  = generate_field_html(form, field)
    label_html  = generate_label_html(form, field, left_column)

    field_html = attach_addon(field_html, field)

    tags = [field_html]
    |> attach_error(form, field)

    wrapper_class = ["form-group"]
    |> attach_error_class(form, field)
    |> attach_required_class(field)

    column = content_tag(:div, tags, class: right_column)

    content_tag(:div, [label_html, column], class: Enum.join(wrapper_class, " "))

  end

end
