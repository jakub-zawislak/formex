defmodule Formex.Template.BootstrapHorizontal do
  use Formex.Template, :main
  import Formex.Template.Bootstrap

  @moduledoc """
  The Bootstrap 3 [horizontal](http://getbootstrap.com/css/#forms-horizontal) template

  ## Options

    * `left_column` - left column class, defaults to `col-sm-2`
    * `right_column` - left column class, defaults to `col-sm-10`
  """

  def generate_row(form, item, options \\ [])

  def generate_row(form, field = %Field{}, options) do

    {left_column, right_column} = get_columns(options)

    input  = generate_input(form, field)
    label  = generate_label(form, field, left_column)

    input = attach_addon(input, field)

    tags = [input]
    |> attach_error(form, field)

    wrapper_class = ["form-group"]
    |> attach_error_class(form, field)
    |> attach_required_class(field)

    column = content_tag(:div, tags, class: right_column)

    content_tag(:div, [label, column], class: Enum.join(wrapper_class, " "))

  end

  def generate_row(form, button = %Button{}, options) do

    {left_column, right_column} = get_columns(options)

    offset = String.replace(left_column, ~r/([0-9]+)$/, "offset-\\1")
    right_column = right_column<>" "<>offset

    input        = generate_input(form, button)
    input_column = content_tag(:div, input, class: right_column)

    content_tag(:div, input_column, class: "form-group")
  end

  defp get_columns(options) do
    {
      Keyword.get(options, :left_column, "col-sm-2"),
      Keyword.get(options, :right_column, "col-sm-10")
    }
  end

end
