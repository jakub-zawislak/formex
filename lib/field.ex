defmodule Formex.Field do
  import Ecto
  import Ecto.Query

  defstruct name: nil,
    assoc: false,
    type: nil,
    value: nil,
    required: true,
    label: "",
    data: [],
    opts: []

  @repo Application.get_env(:formex, :repo)

  def create_field(form, :select_assoc, name_id, opts) do

    name = Regex.replace(~r/_id$/, Atom.to_string(name_id), "") |> String.to_atom

    get_options = fn ->
      module = form.model.__schema__(:association, name).queryable

      query = from e in module,
        select: {e.name, e.id},
        order_by: e.name

      @repo.all(query)
    end

    field = %__MODULE__{
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

  end

  def create_field(form, type, name, opts) do

    field = %__MODULE__{
      name: name,
      type: type,
      value: Map.get(form.struct, name),
      label: get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      opts: opts
    }

  end

  #

  defp get_label(name, opts) do
    if opts[:label] do
      opts[:label]
    else
      Atom.to_string name
    end
  end

end
