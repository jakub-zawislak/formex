defmodule Formex.InputHelpers do
  use Phoenix.HTML

  def array_input(form, field, attr \\ []) do
    default_attr = [
      count: 3
    ]
    merged_attr = attr ++ default_attr
    count = merged_attr[:count]
    values = Phoenix.HTML.Form.input_value(form, field) || []
    values = if Enum.count(values) >= count, do: values, else: List.duplicate("", count - Enum.count(values)) ++ values
    id = Phoenix.HTML.Form.input_id(form,field)
    content_tag :ol, id: container_id(id), class: "input_container", data: [index: Enum.count(values) ] do
      [
        array_add_button(form, field),
        values
        |> Enum.with_index()
        |> Enum.map(fn {value, index} ->
          form_elements(form, field, value, index)
        end)
      ]
    end
  end

  def array_add_button(form, field) do
    id = Phoenix.HTML.Form.input_id(form,field)
    # {:safe, content}
    content = form_elements(form,field,"","__name__")
      |> safe_to_string
      # |> html_escape
    data = [
      prototype: content,
      container: container_id(id)
    ];
    link("Add", to: "#",data: data, class: "add-form-field")
  end

  defp form_elements(form, field, value ,index) do
    type = Phoenix.HTML.Form.input_type(form, field)
    id = Phoenix.HTML.Form.input_id(form,field)
    new_id = id <> "_#{index}"
    input_opts = [
      name: new_field_name(form,field),
      value: value,
      id: new_id,
      class: "form-control"
    ]
    content_tag :li do
      [
        apply(Phoenix.HTML.Form, type, [form, field, input_opts]),
        link("Remove", to: "#", data: [id: new_id], title: "Remove", class: "remove-form-field")
      ]
    end
  end

  defp container_id(id), do: id <> "_container"

  defp new_field_name(form, field) do
    Phoenix.HTML.Form.input_name(form, field) <> "[]"
  end

end