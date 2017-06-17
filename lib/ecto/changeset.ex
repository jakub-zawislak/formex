defmodule Formex.Ecto.Changeset do
  import Ecto.Changeset
  import Ecto.Query
  alias Formex.Form
  alias Formex.FormCollection
  alias Formex.FormNested
  @repo Application.get_env(:formex, :repo)

  @spec create_changeset(form :: Form.t) :: Form.t
  def create_changeset(form) do
    form.struct
    |> cast(form.params, get_normal_fields_names(form))
    |> cast_multiple_selects(form)
    |> cast_embedded_forms(form)
    |> form.type.changeset_after_create_callback(form)
  end

  #

  defp get_normal_fields_names(form) do
    Form.get_fields(form)
    |> filter_normal_fields(form)
    |> Enum.map(&(&1.name))
  end

  # It will find only many_to_many and one_to_many associations (not many_to_one),
  # because the names (field.name) of many_to_one assocs ends with "_id". This is ok
  defp filter_normal_fields(items, form) do
    items
    |> Enum.filter(fn field ->
      form.struct_module.__schema__(:association, field.name) == nil
    end)
  end

  defp cast_multiple_selects(changeset, form) do
    Form.get_fields(form)
    |> Enum.filter(&(&1.type == :multiple_select))
    |> Enum.reduce(changeset, fn field, changeset ->
      module = form.struct_module.__schema__(:association, field.name).related
      ids    = form.params[to_string(field.name)] || []

      associated = module
      |> where([c], c.id in ^ids)
      |> @repo.all
      |> Enum.map(&Ecto.Changeset.change/1)

      changeset
      |> put_assoc(field.name, associated)
    end)
  end

  defp cast_embedded_forms(changeset, form) do
    Form.get_subforms(form)
    |> Enum.reduce(changeset, fn item, changeset ->

      cast_func = if Form.is_assoc(form, item.name) do
        &cast_assoc/3
      else
        &cast_embed/3
      end

      case item do
        %Formex.FormNested{} ->
          changeset
          |> cast_func.(item.name, with: fn _substruct, _params ->
            subform = item.form
            create_changeset(subform)
          end)

        %Formex.FormCollection{} ->
          changeset
          |> cast_func.(item.name, with: fn substruct, params ->

            substruct = if !substruct.id do
              Map.put(substruct, :formex_id, params["formex_id"])
            else
              substruct
            end

            item
            |> FormCollection.get_subform_by_struct(substruct)
            |> case do
              nil -> cast(substruct, %{}, [])

              nested_form ->
                subform = nested_form.form

                changeset = create_changeset(subform)
                |> cast(subform.params, [item.delete_field])

                if get_change(changeset, item.delete_field) do
                  %{changeset | action: :delete}
                else
                  changeset
                end
            end
          end)
      end
    end)
  end

end