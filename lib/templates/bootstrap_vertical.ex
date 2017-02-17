defmodule Formex.Template.BootstrapVertical do
  use Formex.Template, :main
  import Formex.Template.Bootstrap

  @moduledoc """
  The Bootstrap 3 [basic](http://getbootstrap.com/css/#forms-example) template. 
  """

  def generate_row(form, field, _options \\ []) do

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

end
