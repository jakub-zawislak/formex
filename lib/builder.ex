defmodule Formex.Builder do
  import Ecto.Changeset
  alias Formex.Form
  @repo Application.get_env(:formex, :repo)

  def create_form(type, struct, params \\ %{}) do
    %Form{
      type: type,
      struct: struct,
      model: struct.__struct__,
      params: params
    }
    |> type.build_form()
    |> create_changeset()
    # |> IO.inspect
  end

  def insert_form(form) do
    case @repo.insert(form.changeset) do
      {:ok, schema}       -> {:ok, schema}
      {:error, changeset} -> {:error, Map.put(form, :changeset, changeset)}
    end
  end

  def update_form(form) do
    case @repo.update(form.changeset) do
      {:ok, schema}       -> {:ok, schema}
      {:error, changeset} -> {:error, Map.put(form, :changeset, changeset)}
    end
  end

  #

  defp create_changeset(form) do
    changeset = form.struct
    |> cast(form.params, get_fields_names(form))
    |> validate_required(get_required_fields_names(form))

    form
    |> Map.put(:changeset, changeset)
  end

  defp get_fields_names(form) do
    form.fields
    |> Enum.map(&(&1.name))
  end

  defp get_required_fields_names(form) do
    form.fields
    |> Enum.filter(&(&1.required))
    |> Enum.map(&(&1.name))
  end

end
