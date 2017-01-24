defmodule Formex.Form do

  defstruct type: nil,
    struct: nil,
    model: nil,
    fields: [],
    params: %{},
    changeset: nil,
    phoenix_form: nil

  def put_field(form, field) do
    fields = form.fields ++ [field]

    Map.put(form, :fields, fields)
  end

end
