defmodule Formex.Form do
  alias __MODULE__
  alias Formex.Field
  alias Formex.Button
  alias Formex.FormNested
  alias Formex.FormCollection

  @doc """
  Defines the Formex.Form struct.

    * `:type` - the module that implements `Formex.Type`, for example: `App.ArticleType`
    * `:struct` - the struct of your data, for example: `%App.Article{}`
    * `:new_struct` - the `:struct` with `:params` applied
    * `:struct_module` - `struct.__struct__`, for example: `App.Article`
    * `:struct_info` - additional info about struct, that can differs between implementations
      of `Formex.BuilderProtocol`
    * `:items` - list of `Formex.Field` and `Button` structs
    * `:params` - params that will be used in `Ecto.Changeset.cast`
    * `:phoenix_form` - `%Phoenix.HTML.Form{}`
    * `:template` - the module that implements `Formex.Template`, for example:
      `Formex.Template.BootstrapHorizontal`. Can be set via a `Formex.View.formex_form_for` options
    * `:prepare_form_nested` - callback function used by `Formex.Ecto`
    * `:prepare_form_collection` - callback function used by `Formex.Ecto`
    * `:method` - `:post`, `:put` etc. May be used by `Formex.View`.
      E.g. `Formex.Ecto.Builder` sets here `:put` if we editing `struct`, `:post` otherwise.
    * `:opts` - additional data passed in a controller. See: `Formex.Builder.create_form/5`
  """
  defstruct type: nil,
    struct: nil,
    new_struct: nil,
    struct_module: nil,
    struct_info: nil,
    valid?: false,
    errors: [],
    items: [],
    params: %{},
    phoenix_form: nil,
    prepare_form_nested: nil,
    prepare_form_collection: nil,
    method: nil,
    opts: [],
    template: nil,
    template_options: nil

  @type t :: %Form{}

  @doc """
  Adds field to the form. More: `Formex.Field.create_field/4`, `Button.create_button/3`
  """
  @spec put_item(form :: t, item :: any) :: t
  def put_item(form, item) do
    items = form.items ++ [item]

    Map.put(form, :items, items)
  end

  @doc """
  Returns list of `t:Formex.Field.t/0`
  """
  @spec get_fields(form :: t) :: list
  def get_fields(form) do
    form.items
    |> Enum.filter(&(&1.__struct__ == Field))
  end

  @doc """
  Returns list of items which can be validated (all except the `Button`)
  """
  @spec get_fields_validatable(form :: t) :: list
  def get_fields_validatable(form) do
    form.items
    |> Enum.filter(&(&1.__struct__ != Button))
  end

  @doc """
  Returns list of `t:Formex.FormNested.t/0` and `t:Formex.FormCollection.t/0`
  """
  @spec get_subforms(form :: t) :: list
  def get_subforms(form) do
    form.items
    |> Enum.filter(&(&1.__struct__ == FormNested || &1.__struct__ == FormCollection))
  end

  @doc """
  Finds form item by name
  """
  @spec find(form :: t, name :: atom) :: list
  def find(form, name) do
    form.items
    |> Enum.find(&(&1.name == name))
  end

  @doc """
  Returns list of `t:Formex.FormNested.t/0`
  """
  @spec get_nested(form :: t) :: list
  def get_nested(form) do
    form.items
    |> Enum.filter(&(&1.__struct__ == FormNested))
  end

  @doc """
  Returns list of `t:Formex.FormCollection.t/0`
  """
  @spec get_collections(form :: t) :: list
  def get_collections(form) do
    form.items
    |> Enum.filter(&(&1.__struct__ == FormCollection))
  end

  @spec start_creating(form :: Form.t, type :: any, name :: Atom.t, opts :: Map.t) :: Form.t
  def start_creating(form, type, name, opts \\ []) do
    info = form.struct_info[name]

    if is_tuple(info) && elem(info, 0) == :collection do
      Formex.FormCollection.start_creating(form, type, name, opts)
    else
      Formex.FormNested.start_creating(form, type, name, opts)
    end
  end

  @spec finish_creating(form :: Form.t) :: Form.t
  def finish_creating(form) do
    new_items = form.items
    |> Enum.map(fn item ->
      case item do
        %FormCollection{} ->
          FormCollection.finish_creating(form, item)
        %FormNested{} ->
          FormNested.finish_creating(form, item)
        _ ->
          item
      end
    end)

    form
    |> Map.put(:items, new_items)
  end

  @doc false
  @spec get_assoc_or_embed(form :: Form.t, name :: Atom.t) :: any
  def get_assoc_or_embed(form, name) do

    if is_assoc(form, name) do
      form.struct_module.__schema__(:association, name)
    else
      form.struct_module.__schema__(:embed, name)
    end

  end

  @doc false
  @spec is_assoc(form :: Form.t, name :: Atom.t) :: boolean
  def is_assoc(form, name) do
    form.struct_module.__schema__(:association, name) != nil
  end

end
