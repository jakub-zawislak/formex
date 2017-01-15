defmodule Formex.Type do
  import Ecto
  import Ecto.Query

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

    field = %{
      name: name_id,
      type: :select,
      value: Map.get(form.struct, name),
      select_options: get_options.(),
      required: Keyword.get(opts, :required, true)
    }

    put_field(form, field)
  end

  def put_field(form, type, name, opts) do

    field = %{
      name: name,
      type: type,
      value: Map.get(form.struct, name),
      required: Keyword.get(opts, :required, true)
    }

    put_field(form, field)
  end

  #

  defp put_field(form, field) do
    fields = form.fields ++ [field]

    Map.put(form, :fields, fields)
  end

end
