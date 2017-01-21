defmodule Formex.Form do

  defstruct type: nil,
    struct: nil,
    model: nil,
    fields: [],
    params: %{},
    changeset: nil,
    phoenix_form: nil

  defmacro __using__([]) do
    quote do
      def changeset_after_create_callback( changeset ) do
        changeset
      end

      def add(form, type, name_id, opts) do
        field = Formex.Field.create_field(form, type, name_id, opts)

        Formex.Form.put_field(form, field)
      end

      defoverridable [changeset_after_create_callback: 1]
    end
  end

  def put_field(form, field) do
    fields = form.fields ++ [field]

    Map.put(form, :fields, fields)
  end

end
