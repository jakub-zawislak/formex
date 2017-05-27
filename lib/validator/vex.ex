defmodule Formex.Validator.Vex do
  @behaviour Formex.Validator
  alias Formex.Form

  @spec validate(Form.t) :: Form.t
  def validate(form) do

    # errors_struct = if form.type.validate_whole_struct? do
    #   form.struct
    #   |> Vex.errors
    #   |> Enum.reduce([], fn error ->
    #     IO.inspect error

    #   end)
    # else
    #   []
    # end

    errors_type = form
    |> Form.get_fields_validatable
    |> Enum.map(fn item ->
      if item.validation do 
        errors = Map.from_struct(form.struct)
        |> Vex.errors([{item.name, item.validation}])
        |> Enum.map(fn error ->
          elem(error, 3)
        end)

        {item.name, errors}
      else
        {item.name, []}
      end
    end)

    errors = errors_type

    form
    |> Map.put(:errors, errors)
  end

end