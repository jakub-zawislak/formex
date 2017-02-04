defmodule Formex.Builder do
  import Ecto.Changeset
  alias Formex.Form
  @repo Application.get_env(:formex, :repo)

  @moduledoc """
  The form builder.

  Example:

  ```
  form = create_form(App.ArticleType, %Article{})
  render(conn, "new.html", form: form)
  ```

  ```
  App.ArticleType
  |> create_form(%Article{}, article_params)
  |> insert_form_data
  |> case do
    {:ok, _article} ->
      # ...
    {:error, form} ->
      # ...
  end
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

  @doc """
  Invokes `Repo.insert`. In case of `:error`, returns `{:error, form}` (with new `form.changeset`
  value) instead of `{:error, changeset}` (as Ecto does)
  """
  @spec insert_form_data(Form.t) :: {:ok, Ecto.Schema.t} | {:error, Form.t}
  def insert_form_data(form) do
    case @repo.insert(form.changeset) do
      {:ok, schema}       -> {:ok, schema}
      {:error, changeset} -> {:error, Map.put(form, :changeset, changeset)}
    end
  end

  @doc """
  Invokes `Repo.update`. In case of `:error`, returns `{:error, form}` (with new `form.changeset`
  value) instead of `{:error, changeset}` (as Ecto does)
  """
  @spec update_form_data(Form.t) :: {:ok, Ecto.Schema.t} | {:error, Form.t}
  def update_form_data(form) do
    case @repo.update(form.changeset) do
      {:ok, schema}       -> {:ok, schema}
      {:error, changeset} -> {:error, Map.put(form, :changeset, changeset)}
    end
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
    form.fields
    # |> Enum.filter(&(!&1.assoc))
    |> Enum.map(&(&1.name))
  end

  # defp get_assoc_fields_names(form) do
  #   form.fields
  #   |> Enum.filter(&(&1.assoc))
  #   |> Enum.map(&(&1.name))
  # end

  defp get_required_fields_names(form) do
    form.fields
    |> Enum.filter(&(&1.required))
    |> Enum.map(&(&1.name))
  end

end
