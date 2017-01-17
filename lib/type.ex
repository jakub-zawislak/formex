defmodule Formex.Type do
  import Ecto
  import Ecto.Query
  alias Formex.Field

  @repo Application.get_env(:formex, :repo)

  def put_field(form, :select, name, opts) do

    get_options = fn ->
      module = form.model.__schema__(:association, name).queryable

      query = from e in module,
        select: {e.name, e.id},
        order_by: e.name

      @repo.all(query)
    end

    name_id = name
    |> Atom.to_string
    |> Kernel.<>("_id")
    |> String.to_atom

    field = %Field{
      name: name_id,
      type: :select,
      value: Map.get(form.struct, name),
      label: get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      opts: %{
        select_options: get_options.()
      }
    }

    put_field(form, field)
  end

  def put_field(form, type, name, opts) do

    field = %Field{
      name: name,
      type: type,
      value: Map.get(form.struct, name),
      label: get_label(name, opts),
      required: Keyword.get(opts, :required, true)
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
