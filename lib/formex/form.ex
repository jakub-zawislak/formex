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
    * `:params` - sent parameters
    * `:phoenix_form` - `%Phoenix.HTML.Form{}`
    * `:template` - the module that implements `Formex.Template`, for example:
    `Formex.Template.BootstrapHorizontal`. Can be set via a `Formex.View.formex_form_for` options
    * `:method` - `:post`, `:put` etc. May be used by `Formex.View`.
    E.g. `Formex.Ecto.Builder` sets here `:put` if we editing `struct`, `:post` otherwise.
    * `:submitted?` - is form submitted? Set by `Formex.Controller.handle_form/1`
    * `:opts` - additional data passed in a controller. See: `Formex.Builder.create_form/5`
  """
  defstruct type: nil,
    struct: nil,
    new_struct: nil,
    struct_module: nil,
    struct_info: nil,
    valid?: false,
    items: [],
    params: %{},
    phoenix_form: nil,
    template: nil,
    method: nil,
    submitted?: false,
    opts: [],
    errors: [],
    template_options: nil,
    mapped_params: %{}

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
  Returns list of items which user can control (all except the `Button`)
  """
  @spec get_fields_controllable(form :: t) :: list
  def get_fields_controllable(form) do
    form.items
    |> Enum.filter(&(&1.__struct__ != Button))
  end

  @doc """
  Returns list of items which can be validated (alias for `get_fields_controllable/1`)
  """
  @spec get_fields_validatable(form :: t) :: list
  def get_fields_validatable(form) do
    get_fields_controllable(form)
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
  Finds form item by struct name
  """
  @spec find_by_struct_name(form :: t, name :: atom) :: list
  def find_by_struct_name(form, name) do
    form.items
    |> Enum.find(&(&1.struct_name == name))
  end

  @doc """
  Finds form item by struct name
  """
  @spec get_struct_name_by_name(form :: t, name :: atom) :: list
  def get_struct_name_by_name(form, name) do
    find(form, name)
    |> Map.get(:struct_name)
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

  @doc """
  Returns list of names of items with changed name (`item.name` != `item.struct_name`)
  """
  @spec get_items_with_changed_name(form :: t) :: list
  def get_items_with_changed_name(form) do
    form
    |> get_fields_controllable
    |> Enum.filter(&(&1.name != &1.struct_name))
    |> Enum.map(&(&1.name))
  end

  @doc false
  @spec start_creating(form :: Form.t, type :: any, name :: Atom.t, opts :: Map.t) :: Form.t
  def start_creating(form, type, name, opts \\ []) do
    info = form.struct_info[name]

    if is_tuple(info) && elem(info, 0) == :collection do
      Formex.FormCollection.start_creating(form, type, name, opts)
    else
      Formex.FormNested.start_creating(form, type, name, opts)
    end
  end

  @doc false
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

  # applies function for every select field
  @doc false
  @spec modify_selects_recursively(form :: Form.t, fun :: (Field.t, Form.t -> Field.t)) :: Form.t
  def modify_selects_recursively(form, fun) do

    form_items = Enum.map(form.items, fn item ->

      case item do
        collection = %FormCollection{} ->
          forms = collection.forms
          |> Enum.with_index()
          |> Enum.map(fn {nested, index} ->
            form = modify_selects_recursively(nested.form, fun)

            %{nested | form: form}
          end)
          %{collection | forms: forms}

        nested = %FormNested{} ->
          %{nested | form: modify_selects_recursively(nested.form, fun)}

        field = %Field{} ->
          if field.type in [:select, :multiple_select] do
            fun.(form, field)
          else
            field
          end

        _ -> item
        end
      end)

    Map.put(form, :items, form_items)
  end

end
