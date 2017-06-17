defmodule Formex.Validator do
  alias Formex.Form
  alias Formex.FormCollection
  alias Formex.FormNested

  @callback validate(form :: Formex.Form.t) :: List.t

  @spec validate(Form.t) :: Form.t
  def validate(form) do
    validator = Application.get_env(:formex, :validator)

    form = validator.validate(form)

    items = form.items
    |> Enum.map(fn item ->
      case item do
        collection = %FormCollection{} ->
          %{collection | forms: Enum.map(collection.forms, fn nested ->
            if !FormCollection.to_be_removed(item, nested) do
              %{nested | form: validate(nested.form)}
            else
              %{nested | form: %{nested.form | valid?: true}}
            end
          end)}
        nested = %FormNested{} ->
          %{nested | form: validate(nested.form)}
        _ ->
          item
      end
    end)

    form = %{form | items: items}

    Map.put(form, :valid?, valid?(form))
  end

  #

  @spec valid?(Form.t) :: boolean
  defp valid?(form) do
    valid? = Enum.reduce_while(form.errors, true, fn {k, v}, _acc ->
      if Enum.count(v) > 0,
        do:   {:halt, false},
        else: {:cont, true}
    end)

    valid? && nested_valid?(form) && collections_valid?(form)
  end

  @spec nested_valid?(Form.t) :: boolean
  defp nested_valid?(form) do
    Form.get_nested(form)
    |> Enum.reduce_while(true, fn item, _acc ->
      if item.form.valid?,
        do:   {:cont, true},
        else: {:halt, false}
    end)
  end

  @spec collections_valid?(Form.t) :: boolean
  defp collections_valid?(form) do
    Form.get_collections(form)
    |> Enum.reduce_while(true, fn collection, _acc ->
      collection.forms
      |> Enum.reduce_while(true, fn item, _sub_acc ->
        if item.form.valid?,
          do:   {:cont, true},
          else: {:halt, false}
      end)
      |> case do
        true  -> {:cont, true}
        false -> {:halt, false}
      end
    end)
  end
end