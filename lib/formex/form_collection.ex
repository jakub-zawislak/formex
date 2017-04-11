defmodule Formex.FormCollection do
  @repo Application.get_env(:formex, :repo)
  alias __MODULE__
  alias Formex.Field
  alias Formex.Form
  alias Formex.FormNested

  defstruct forms: [],
    model: nil,
    name: nil,
    opts: [],
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

    submodule = Form.get_assoc_or_embed(form, name).related

    params = form.params[to_string(name)] || []

    subforms_old = create_existing_subforms(name, substructs, params, type, submodule, opts)
    subforms_new = create_new_subforms(name, params, type, submodule, opts)

    form_collection = %FormCollection{
      forms: subforms_old ++ subforms_new,
      name: name,
      model: submodule,
      required: Keyword.get(opts, :required, true),
      opts: opts
    }

    {form, form_collection}
  end

  defp create_existing_subforms(name, substructs, params, type, submodule, opts) do
    substructs
    |> Enum.map(fn substruct ->
      {_, subparams} = Enum.find(params, {nil, %{}}, fn {_k, v} ->
        id = if is_integer(substruct.id) do
          v["id"] |> Integer.parse |> elem(0)
        else
          v["id"]
        end
        substruct.id == id
      end)

      create_subform(name, type, substruct, subparams, submodule, opts)
    end)
  end

  defp create_new_subforms(name, params, type, submodule, opts) do
      params
      |> Enum.filter(fn {_key, val} -> !val["id"] end)
      |> Enum.map(fn {_key, subparams} ->
        substruct = struct(submodule, subparams)

        create_subform(name, type, substruct, subparams, submodule, opts)
      end)
  end

  defp create_subform(name, type, substruct, subparams, submodule, opts) do
    subform = Formex.Builder.create_form(type, substruct, subparams, submodule)

    %FormNested{
      form: subform,
      name: name,
      required: Keyword.get(opts, :required, true),
      opts: opts
    }
  end

end
