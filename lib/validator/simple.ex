defmodule Formex.Validator.Simple do
  @behaviour Formex.Validator
  alias Formex.Form

  @moduledoc """
  Very simple validator.

  # Usage:

  There is only one option you can use: `:required`.

  ```
  def build_form(form) do
    form
    |> add(:name, :text_input, validation: [:required])
    |> add(:content, :textarea, validation: [:required])
    # ...
  end
  ```
  """

  @spec validate(Form.t) :: Form.t
  def validate(form) do

    errors = form
    |> Form.get_fields_validatable
    |> Enum.map(fn item ->
      if item.validation do
        errors = form.new_struct
        |> Map.from_struct()
        |> Map.get(item.name)
        |> do_validation(item.validation)

        {item.name, errors}
      else
        {item.name, []}
      end
    end)

    form
    |> Map.put(:errors, errors)
  end

  @spec do_validation(value :: any, rules :: List.t) :: List.t
  defp do_validation(value, rules) do
    rules
    |> Enum.map(fn rule ->
      case rule do
        :required ->
          if (is_binary(value) && value == "") || (!value) do
            "This field is required"
          end
      end
    end)
    |> Enum.filter(&(&1))
    |> Enum.map(fn message ->
      {message, []}
    end)
  end

end
