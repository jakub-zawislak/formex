defmodule Formex.Form do
  @repo Application.get_env(:formex, :repo)
  alias __MODULE__
  alias Formex.Field
  alias Formex.Button

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
  """
  defstruct type: nil,
    struct: nil,
    model: nil,
    items: [],
    params: %{},
    changeset: nil,
    phoenix_form: nil,
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
  Returns list of `t:Formex.Field.t/0` and `t:Formex.Form.t/0` (embeded forms)
  """
  @spec get_fields(form :: t) :: list
  def get_fields(form) do
    Enum.filter(form.items, &(&1.__struct__ == Formex.Field))
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

    substruct = Field.get_value(form, name)

    {form, substruct} = if Ecto.assoc_loaded? substruct do
      {form, substruct}
    else
      struct     = @repo.preload(form.struct, name)
      substruct = Map.get(struct, name)

      struct = Map.put(struct, name, substruct)
      form   = Map.put(form, :struct, struct)

      {form, substruct}
    end

    submodule = if substruct do
      substruct.__struct__
    else
      form.model.__schema__(:association, name).queryable
    end

    params = form.params[to_string(name)] || %{}

    subform = Formex.Builder.create_form(type, substruct, params, submodule)

    item = Formex.Field.create_field(form, subform, name, opts)

    {form, item}
  end

end
