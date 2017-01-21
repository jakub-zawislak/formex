defmodule Formex.Type do
  import Ecto
  import Ecto.Query
  alias Formex.Field

  @repo Application.get_env(:formex, :repo)

  defmacro __using__([]) do
    quote do
      def changeset_callback( changeset ) do
        changeset
      end

      def add(form, type, name_id, opts) do
        Formex.Type.add_field(form, type, name_id, opts)
      end

      defoverridable [changeset_callback: 1]
    end
  end

  def add_field(form, :select_assoc, name_id, opts) do

    name = Regex.replace(~r/_id$/, Atom.to_string(name_id), "") |> String.to_atom

    get_options = fn ->
      module = form.model.__schema__(:association, name).queryable

      query = from e in module,
        select: {e.name, e.id},
        order_by: e.name

      @repo.all(query)
    end

    field = %Field{
      name: name_id,
      type: :select,
      value: Map.get(form.struct, name),
      label: get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      data: [
        options: get_options.()
      ],
      opts: opts
    }

    put_field(form, field)
  end

  def add_field(form, type, name, opts) do

    field = %Field{
      name: name,
      type: type,
      value: Map.get(form.struct, name),
      label: get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      opts: opts
    }

    put_field(form, field)
  end

  #

  defp get_label(name, opts) do
    if opts[:label] do
      opts[:label]
    else
      Atom.to_string name
    end
  end

  defp put_field(form, field) do
    fields = form.fields ++ [field]

    Map.put(form, :fields, fields)
  end

end
