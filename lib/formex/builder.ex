defmodule Formex.Builder do
  import Ecto.Changeset
  alias Formex.Form

  @moduledoc """
  The form builder to be used in a controller. Imported by `Formex.Controller`.

  Example:

  ```
  form = create_form(App.ArticleType, %Article{})
  render(conn, "new.html", form: form)
  ```
  """

  @doc """
  Creates a form struct.

  ## Arguments

    * `type` - the module that implements `Formex.Type` behaviour, for example: `App.ArticleType`
    * `struct` - the struct that will be used in `Ecto.Changeset.cast/3`, for example: `%App.Article{}`
    * `params` - the parameters that will be used in `Ecto.Changeset.cast/3`
  """
  @spec create_form(module, Ecto.Schema.t, Map.t) :: Form.t
  def create_form(type, struct, params \\ %{}) do
    %Form{
      type: type,
      struct: struct,
      model: struct.__struct__,
      params: params
    }
    |> type.build_form()
    |> create_changeset(type)
    # |> IO.inspect
  end

  #

  defp create_changeset(form, type) do
    changeset = form.struct
    |> cast(form.params, get_normal_fields_names(form))
    |> validate_required(get_required_fields_names(form))
    |> type.changeset_after_create_callback

    form
    |> Map.put(:changeset, changeset)
  end

  defp get_normal_fields_names(form) do
    form.items
    |> filter_fields
    # |> Enum.filter(&(!&1.assoc))
    |> Enum.map(&(&1.name))
  end

  # defp get_assoc_fields_names(form) do
  #   form.items
  #   |> Enum.filter(&(&1.assoc))
  #   |> Enum.map(&(&1.name))
  # end

  defp get_required_fields_names(form) do
    form.items
    |> filter_fields
    |> Enum.filter(&(&1.required))
    |> Enum.map(&(&1.name))
  end

  defp filter_fields(items) do
    Enum.filter(items, &(&1.__struct__ == Formex.Field))
  end

end
