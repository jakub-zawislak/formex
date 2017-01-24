defmodule Formex.Field do
  import Ecto.Query
  alias __MODULE__

  @doc """
  Defines the Formex.Field struct.

    * `:name` - a field name, for example: `:title`
    * `:type` - type of field that in most cases will be name of function from `Phoenix.HTML.Form`
    * `:value` - the value from struct/params
    * `:required` - is field required?
    * `:label` - the text label
    * `:data` - additional data used by particular field type (eg. `:select_assoc` stores here data
      for `<option>`'s)
    * `:opts` - options
  """
  defstruct name: nil,
    # assoc: false,
    type: nil,
    value: nil,
    required: true,
    label: "",
    data: [],
    opts: []

  @type t :: %Field{}

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

    %Field{
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

    %Field{
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
