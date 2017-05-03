defmodule Formex.Validator do
  alias Formex.Form

  @spec validate(Form.t) :: Form.t
  def validate(form) do
    validator = Application.get_env(:formex, :validator)

    validator.validate(form)

    # obsłuyć nested i kolekcje

    # wyliczyć `valid?`

    # jeszcze validate_whole_struct
  end

  @callback validate(form :: Formex.Form.t) :: List.t
end