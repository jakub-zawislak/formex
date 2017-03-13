defmodule Formex.FormCollection do
  @repo Application.get_env(:formex, :repo)
  alias __MODULE__
  alias Formex.Field
  alias Formex.Form
  alias Formex.FormNested

  defstruct prototype: nil,
    forms: [],
    name: nil,
    required: true

  @type t :: %FormCollection{}

  @spec create(form :: Form.t, type :: any, name :: Atom.t, opts :: Map.t) :: Form.t
  def create(form, type, name, opts) do
    substructs = Field.get_value(form, name)

    {form, substructs} = if Ecto.assoc_loaded? substructs do
      {form, substructs}
    else
      struct    = @repo.preload(form.struct, name)
      substructs = Map.get(struct, name)

      struct = Map.put(struct, name, substructs)
      form   = Map.put(form, :struct, struct)

      {form, substructs}
    end

    submodule = form.model.__schema__(:association, name).queryable

    params = form.params[to_string(name)] || []

    # tutaj są tylko formy na podstawie bazy
    subforms = substructs
    |> Enum.map(fn substruct ->
      {_, subparams} = Enum.find(params, {nil, %{}}, fn {k, v} ->
        substruct.id == v["id"] |> Integer.parse |> elem(0)
      end)

      subform = Formex.Builder.create_form(type, substruct, subparams, submodule)
      %FormNested{
        form: subform,
        name: name,
        required: Keyword.get(opts, :required, true),
        opts: opts
      }
    end)

    # trzeba jeszcze obsłużyć kolejne formy (spoza bazy)

    form_collection = %FormCollection{forms: subforms, name: name}

    {form, form_collection}
  end

end
