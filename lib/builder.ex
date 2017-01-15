defmodule Formex.Builder do
  import Ecto.Changeset

  def create_form(type, struct) do
    %{
      type: type,
      struct: struct,
      model: struct.__struct__,
      fields: [],
      params: %{},
      changeset: nil
    }
  end

  def handle_request(form, params) do
    form
    |> Map.put(:params, params)
    |> form.type.build_form()
    |> create_changeset()
    # |> IO.inspect
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
