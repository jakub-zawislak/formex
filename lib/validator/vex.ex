defmodule Formex.Validator.Vex do
  @behaviour Formex.Validator
  alias Formex.Form

  @spec validate(Form.t) :: Form.t
  def validate(form) do

    if form.type.validate_whole_struct? do
    else
    end

    errors = form
    |> Form.get_fields_validatable
    |> Enum.map(fn item ->
      errors = Map.from_struct(form.struct)
      |> Vex.errors([{item.name, item.validation}])
      |> Enum.map(fn error ->
        elem(error, 3)
      end)

      {item.name, errors}
    end)

    form
    |> Map.put(:errors, errors)
  end

end