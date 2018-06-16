defmodule Formex.FormCollection do
  alias __MODULE__
  alias Formex.Field
  alias Formex.Form
  alias Formex.FormNested

  defstruct forms: [],
            struct_module: nil,
            name: nil,
            # added only for compability with validation libs which look for `struct_name`
            struct_name: nil,
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

  * `type` - module that implements `Formex.Type`. Required
  * `struct_module` - module of struct, e.g. `App.UserAddress`
  * `delete_field` - defaults to `:formex_delete`. Defines input that will be set to true
    if we click &times;. Behaviours depends on value:
      * `:formex_delete` - if `formex_delete` is true, this collection item
        will be removed.
      * another field - it's a simple input that may be stored in repo

        For example, we can in our model create `removed` field. Then set
        `delete_field: :removed` option.
  """

  @doc false
  @spec start_creating(form :: Form.t(), type :: any, name :: Atom.t(), opts :: Map.t()) :: Map.t()
  def start_creating(form, type, name, opts) do
    {:collection, submodule} = form.struct_info[name]

    submodule =
      if submodule do
        submodule
      else
        Keyword.get(opts, :struct_module) || raise "the :struct_module option is required"
      end

    {delete_field, opts} = Keyword.pop(opts, :delete_field)

    %FormCollection{
      name: name,
      # struct_name: Keyword.get(opts, :struct_name, name), # not handled yet
      struct_name: name,
      type: type,
      opts: opts,
      struct_module: submodule,
      validation: Keyword.get(opts, :validation, []),
      delete_field: delete_field || :formex_delete
    }
  end

  # called when substructs are ready
  @doc false
  @spec finish_creating(form :: Form.t(), form_collection :: FormCollection.t()) :: Form.t()
  def finish_creating(form, form_collection) do
    substructs = Field.get_value(form, form_collection.name)

    # substructs = if opts[:filter] do
    #   Enum.filter(substructs, opts[:filter])
    # else
    #   substructs
    # end

    params = form.params[to_string(form_collection.name)] || []

    subforms_old = create_existing_subforms(form, form_collection, params, substructs)
    subforms_new = create_new_subforms(form, form_collection, params)

    form_collection
    |> Map.put(:forms, subforms_old ++ subforms_new)
  end

  @doc false
  @spec get_subform_by_struct(form_collection :: t, struct :: Map.t()) :: FormNested.t()
  def get_subform_by_struct(form_collection, struct) do
    form_collection.forms
    |> Enum.find(fn form_nested ->
      if struct.id && struct.id !== "" do
        to_string(form_nested.form.struct.id) == to_string(struct.id)
      else
        form_nested.form.struct.formex_id == struct.formex_id
      end
    end)
  end

  defp create_existing_subforms(form, form_collection, params, substructs) do
    substructs
    |> Enum.map(fn substruct ->
      {_, subparams} =
        Enum.find(params, {nil, %{}}, fn {_k, v} ->
          id =
            if is_integer(substruct.id) do
              v["id"] |> Integer.parse() |> elem(0)
            else
              v["id"]
            end

          substruct.id == id
        end)

      create_subform(form, form_collection, substruct, subparams)
    end)
  end

  defp create_new_subforms(form, form_collection, params) do
    %{struct_module: submodule} = form_collection

    params
    |> Enum.filter(fn {_key, val} -> !val["id"] end)
    |> Enum.map(fn {key, val} -> {String.to_integer(key), val} end)
    |> Enum.sort_by(fn {key, _} -> key end, fn key1, key2 -> key1 < key2 end)
    |> Enum.map(fn {_key, subparams} ->
      substruct = struct(submodule, formex_id: subparams["formex_id"])

      create_subform(form, form_collection, substruct, subparams)
    end)
  end

  defp create_subform(form, form_collection, substruct, subparams) do
    %{name: name, type: type, struct_module: submodule, opts: opts} = form_collection

    subform =
      Formex.Builder.create_form(
        type,
        substruct,
        subparams,
        form.opts,
        submodule
      )

    %FormNested{
      form: subform,
      name: name,
      validation: Keyword.get(opts, :validation, []),
      struct_module: submodule,
      type: type,
      opts: opts
    }
  end

  @spec to_be_removed(form_collection :: t, form_nested :: FormNested.t()) :: boolean
  @doc false
  def to_be_removed(form_collection, form_nested) do
    val = Map.get(form_nested.form.new_struct, form_collection.delete_field)

    val == "true"
  end
end
