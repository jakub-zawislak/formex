defmodule Formex.FormCollection do
  @repo Application.get_env(:formex, :repo)
  alias __MODULE__
  alias Formex.Field
  alias Formex.Form
  alias Formex.FormNested

  defstruct forms: [],
    struct_module: nil,
    name: nil,
    opts: [],
    delete_field: nil,
    required: true

  @type t :: %FormCollection{}

  @moduledoc """
  Form collections

  To get started see `Formex.Type`, section _Collections of forms_.

  Functionality that are not mentioned in the link above:

  ## Options
  
  * `delete_field` - defaults to `:formex_delete`. Defines input that will be set to true
    if we click &times;. Behaviours depends on value:
      * `:formex_delete` - if `formex_delete` is true, this collection item 
        will be removed. 
      * another field - it's a simple input that may be stored in repo
      
        For example, we can in our model create `removed` field. Then set 
        `delete_field: :removed` option.
  """

  @spec create(form :: Form.t, type :: any, name :: Atom.t, opts :: Map.t) :: Form.t
  def create(form, type, name, opts) do
    substructs = Field.get_value(form, name)

    {delete_field, opts} = Keyword.pop(opts, :delete_field)

    {form, substructs} = if Ecto.assoc_loaded? substructs do
      {form, substructs}
    else
      struct    = @repo.preload(form.struct, name)
      substructs = Map.get(struct, name)

      struct = Map.put(struct, name, substructs)
      form   = Map.put(form, :struct, struct)

      {form, substructs}
    end

    # substructs = if opts[:filter] do
    #   Enum.filter(substructs, opts[:filter])
    # else
    #   substructs
    # end

    submodule = Form.get_assoc_or_embed(form, name).related

    params = form.params[to_string(name)] || []

    subforms_old = create_existing_subforms(form, name, substructs, params, type, submodule, opts)
    subforms_new = create_new_subforms(form, name, params, type, submodule, opts)

    form_collection = %FormCollection{
      forms: subforms_old ++ subforms_new,
      name: name,
      struct_module: submodule,
      required: Keyword.get(opts, :required, true),
      opts: opts,
      delete_field: delete_field || :formex_delete
    }

    {form, form_collection}
  end

  @doc false
  @spec get_subform_by_struct(form_collection :: t, struct :: Map.t) :: FormNested.t
  def get_subform_by_struct(form_collection, struct) do
    form_collection.forms
    |> Enum.find(fn form_nested ->
      if struct.id do
        form_nested.form.struct.id == struct.id
      else
        form_nested.form.struct.formex_id == struct.formex_id
      end
    end)
  end

  defp create_existing_subforms(form, name, substructs, params, type, submodule, opts) do
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

      create_subform(form, name, type, substruct, subparams, submodule, opts)
    end)
  end

  defp create_new_subforms(form, name, params, type, submodule, opts) do
    params
    |> Enum.filter(fn {_key, val} -> !val["id"] end)
    |> Enum.map(fn {_key, subparams} ->
      substruct = struct(submodule, [formex_id: subparams["formex_id"]])

      create_subform(form, name, type, substruct, subparams, submodule, opts)
    end)
  end

  defp create_subform(form, name, type, substruct, subparams, submodule, opts) do
    subform = Formex.Builder.create_form(type, substruct, subparams, form.opts, submodule)

    %FormNested{
      form: subform,
      name: name,
      required: Keyword.get(opts, :required, true),
      opts: opts
    }
  end

end
