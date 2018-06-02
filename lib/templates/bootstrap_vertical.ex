defmodule Formex.Template.BootstrapVertical do
  use Formex.Template, :main
  use Formex.Template.Bootstrap

  @moduledoc """
  The Bootstrap 3 [basic](http://getbootstrap.com/css/#forms-example) template.
  """

  def generate_row(form, item, options \\ [])

  def generate_row(form, field = %Field{}, _options) do
    input = generate_input(form, field)
    label = generate_label(form, field)

    input = attach_addon(input, field)

    tags =
      [label, input]
      |> attach_error(form, field)

    wrapper_class =
      ["form-group"]
      |> attach_error_class(form, field)
      |> attach_required_class(field)

    content_tag(:div, tags, class: Enum.join(wrapper_class, " "))
  end

  def generate_row(form, button = %Button{}, _options) do
    generate_input(form, button)
  end
end
