defmodule Formex.FormNested do
  @repo Application.get_env(:formex, :repo)
  alias __MODULE__
  alias Formex.Field
  alias Formex.Form

  defstruct form: nil,
    name: nil,
    validation: [],
    opts: []

  @type t :: %FormNested{}

  @spec create(form :: Form.t, type :: any, name :: Atom.t, opts :: Map.t) :: Form.t
  def create(form, type, name, opts) do
    substruct = Field.get_value(form, name)

    {form, substruct} = if Ecto.assoc_loaded? substruct do
      {form, substruct}
    else
      struct    = @repo.preload(form.struct, name)
      substruct = Map.get(struct, name)

      struct = Map.put(struct, name, substruct)
      form   = Map.put(form, :struct, struct)

      {form, substruct}
    end

    submodule = Form.get_assoc_or_embed(form, name).related
    params    = form.params[to_string(name)] || %{}

    subform = Formex.Builder.create_form(type, substruct, params, form.opts, submodule)
    item    = %FormNested{
      form: subform,
      name: name,
      validation: Keyword.get(opts, :validation, []),
      opts: opts
    }

    {form, item}
  end

end
