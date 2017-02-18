defmodule Formex.Form do
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

end
