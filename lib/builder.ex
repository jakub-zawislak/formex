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
    |> create_changeset(type)
    # |> IO.inspect
  end

  def insert_form_data(form) do
    case @repo.insert(form.changeset) do
      {:ok, schema}       -> {:ok, schema}
      {:error, changeset} -> {:error, Map.put(form, :changeset, changeset)}
    end
  end

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
    |> Enum.filter(&(!&1.assoc))
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
