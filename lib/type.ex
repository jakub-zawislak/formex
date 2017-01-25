defmodule Formex.Type do

  defmacro __using__([]) do
    quote do
      @behaviour Formex.Type

      def changeset_after_create_callback( changeset ) do
        changeset
      end

      def add(form, type, name, opts) do
        field = Formex.Field.create_field(form, type, name, opts)

        Formex.Form.put_field(form, field)
      end

      defoverridable [changeset_after_create_callback: 1]
    end
  end

  @callback build_form(form :: Formex.Form.t) :: Formex.Form.t

  @callback changeset_after_create_callback(changeset :: Ecto.Changeset.t) :: Ecto.Changeset.t

  @doc """
  Adds field to form. More: `Formex.Field.create_field/4`
  """
  @callback add(form :: Form.t, type :: Atom.t, name :: Atom.t, opts :: Map.t) :: Form.t

end
