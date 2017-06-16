defmodule Formex.FormCollection do
  alias __MODULE__
  alias Formex.Field
  alias Formex.Form
  alias Formex.FormNested

  defstruct forms: [],
    struct_module: nil,
    name: nil,
    opts: [],
    delete_field: nil,
    validation: [],
    type: nil

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

  @spec start_creating(form :: Form.t, type :: any, name :: Atom.t, opts :: Map.t) :: Map.t
  def start_creating(form, type, name, opts) do

    {:collection, submodule} = form.struct_info[name]

    submodule = if !submodule do
      Keyword.get(opts, :struct_module) || raise "the :struct_module option is required"
    else
      submodule
    end

    {delete_field, opts} = Keyword.pop(opts, :delete_field)

    form_collection = %FormCollection{
      name: name,
      type: type,
      opts: opts,
      struct_module: submodule,
      validation: Keyword.get(opts, :validation, []),
      delete_field: delete_field || :formex_delete
    }

    form_collection
  end

  # called when substruct are ready
  @spec finish_creating(form :: Form.t, form_collection :: FormCollection.t) :: Form.t
  def finish_creating(form, form_collection) do
    %{name: name, struct_module: struct_module, type: type, opts: opts} = form_collection

    substructs = Field.get_value(form, name)

    # substructs = if opts[:filter] do
    #   Enum.filter(substructs, opts[:filter])
    # else
    #   substructs
    # end

    params = form.params[to_string(name)] || []

    subforms_old = create_existing_subforms(form, name, substructs, params, type, struct_module, opts)
    subforms_new = create_new_subforms(form, name, params, type, struct_module, opts)

    form_collection
    |> Map.put(:forms, subforms_old ++ subforms_new)
  end

  @doc false
  @spec get_subform_by_struct(form_collection :: t, struct :: Map.t) :: FormNested.t
  def get_subform_by_struct(form_collection, struct) do
    form_collection.forms
    |> Enum.find(fn form_nested ->
      if struct.id do
        to_string(form_nested.form.struct.id) == to_string(struct.id)
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

    subform = Formex.Builder2.create_form(type, substruct, subparams, form.opts, submodule)

    %FormNested{
      form: subform,
      name: name,
      validation: Keyword.get(opts, :validation, []),
      struct_module: submodule,
      type: type,
      opts: opts
    }
  end

end
