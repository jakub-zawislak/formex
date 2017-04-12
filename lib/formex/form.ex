defmodule Formex.Form do
  @repo Application.get_env(:formex, :repo)
  alias __MODULE__
  alias Formex.Field
  alias Formex.FormNested
  alias Formex.FormCollection

  @doc """
  Defines the Formex.Form struct.

    * `:type` - the module that implements `Formex.Type`, for example: `App.ArticleType`
    * `:struct` - the struct that will be used in `Ecto.Changeset.cast`, for example: `%App.Article{}`
    * `:model` - `struct.__struct__`, for example: `App.Article`
    * `:items` - list of `Formex.Field` and `Formex.Button` structs
    * `:params` - params that will be used in `Ecto.Changeset.cast`
    * `:changeset` - `%Ecto.Changeset{}`
    * `:phoenix_form` - `%Phoenix.HTML.Form{}`
    * `:template` - the module that implements `Formex.Template`, for example:
      `Formex.Template.BootstrapHorizontal`. Can be set via a `Formex.View.formex_form_for` options
    * `:opts` - additional data passed in a controller. See: `Formex.Builder.create_form/5`
  """
  defstruct type: nil,
    struct: nil,
    model: nil,
    items: [],
    params: %{},
    changeset: nil,
    phoenix_form: nil,
    opts: [],
    template: nil,
    template_options: nil

  @type t :: %Form{}

  @doc """
  Adds field to the form. More: `Formex.Field.create_field/4`, `Formex.Button.create_button/3`
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
  Returns list of `t:Formex.FormNested.t/0` and `t:Formex.FormCollection.t/0`
  """
  @spec get_subforms(form :: t) :: list
  def get_subforms(form) do
    form.items
    |> Enum.filter(&(&1.__struct__ == FormNested || &1.__struct__ == FormCollection))
  end

  @doc """
  Creates a form for assoc.

  Example:

  ```
  form
  |> add_form(:user_info, App.UserInfoType)
  ```

  ## Options

    * `required` - is the subform required.

      Defaults to `true`. This option will be passed to `Ecto.Changeset.cast_assoc/3`
  """
  @spec create_subform(form :: Form.t, type :: any, name :: Atom.t, opts :: Map.t) :: Form.t
  def create_subform(form, type, name, opts \\ []) do

    case get_assoc_or_embed(form, name).cardinality do
      :one  -> Formex.FormNested.create(form, type, name, opts)
      :many -> Formex.FormCollection.create(form, type, name, opts)
    end

  end

  @doc false
  @spec get_assoc_or_embed(form :: Form.t, name :: Atom.t) :: any
  def get_assoc_or_embed(form, name) do

    if is_assoc(form, name) do
      form.model.__schema__(:association, name)
    else
      form.model.__schema__(:embed, name)
    end

  end

  @doc false
  @spec is_assoc(form :: Form.t, name :: Atom.t) :: boolean
  def is_assoc(form, name) do
    form.model.__schema__(:association, name) != nil
  end

end
