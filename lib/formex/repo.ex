defmodule Formex.Repo do
  alias Formex.Form
  @repo Application.get_env(:formex, :repo)

  @moduledoc """
  Helper repo functions to be used in a controller. Imported by `Formex.Controller`.

  Example:

  ```
  form
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

    # form = put_in(form.changeset.changes[:user_info].action, :insert)

    case @repo.update(form.changeset) do
      {:ok, schema}       -> {:ok, schema}
      {:error, changeset} -> {:error, Map.put(form, :changeset, changeset)}
    end
  end

end
