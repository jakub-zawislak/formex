defmodule Formex.Form do
  alias __MODULE__
  alias Formex.Field

  @doc """
  Defines the Formex.Form struct.

    * `:type` - the module that implements `Formex.Type`, for example: `App.ArticleType`
    * `:struct` - the struct that will be used in `Ecto.Changeset.cast`, for example: `%App.Article{}`
    * `:model` - `struct.__struct__`, for example: `App.Article`
    * `:fields` - list of `Formex.Field` structs
    * `:params` - params that will be used in `Ecto.Changeset.cast`
    * `:changeset` - `%Ecto.Changeset{}`
    * `:phoenix_form` - `%Phoenix.HTML.Form{}`
  """
  defstruct type: nil,
    struct: nil,
    model: nil,
    fields: [],
    params: %{},
    changeset: nil,
    phoenix_form: nil

  @type t :: %Form{}

  @doc """
  Adds field to form. More: `Formex.Field.create_field/4`
  """
  @spec put_field(t, Field.t) :: t
  def put_field(form, field) do
    fields = form.fields ++ [field]

    Map.put(form, :fields, fields)
  end

end
