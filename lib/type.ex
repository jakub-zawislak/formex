defmodule Formex.Type do

  defmacro __using__([]) do
    quote do
      @behaviour Formex.Type

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

  @callback build_form(Formex.Form.t) :: Formex.Form.t

  @callback changeset_after_create_callback(Ecto.Changeset.t) :: Ecto.Changeset.t

end
