defmodule Formex.Field.Select.ValidationError do
  defexception [:message]
end

defmodule Formex.Field.Select do
  @moduledoc false

  alias Formex.Field
  alias Formex.Field.Select.ValidatorError

  @spec handle_select_without_choices(field :: Field.t, val :: String.t) :: Field.t
  def handle_select_without_choices(field, val) do
    if field.opts[:choice_label_provider] && val do

      choices = case field.type do
        :select ->
          label = field.opts[:choice_label_provider].(val)

          if label do
            [{label, val}]
          else
            []
          end

        :multiple_select ->
          Enum.map(val, fn subval ->
            # dirty fix for Ecto (and maybe others?) implementations,
            # where at first there is a preloaded struct, and after submit there is just an id.
            subval = if is_map(subval) do
              subval.id
            else
              subval
            end

            {field.opts[:choice_label_provider].(subval), subval}
          end)
          |> Enum.filter(fn {label, val} -> label end)
      end

      data = field.data
      |> Keyword.merge( [choices: choices] )

      %{field | data: data}
    else
      field
    end
  end

  @spec validate(field :: Field.t, val :: String.t) :: Field.t
  def validate(field, val) when is_nil(val) do
    field
  end

  @spec validate(field :: Field.t, val :: String.t) :: Field.t
  def validate(field, val) do
    choices = Enum.map(field.data[:choices], fn choice ->
      case choice do
        opts when is_list(opts) ->
          opts[:value]
        {_, value} ->
          value
        value ->
          value
      end
    end)
    |> Enum.map(&(&1 |> to_string))

    invalid = case field.type do
      :select ->
        String.length(val) > 0 && !(val in choices)
      :multiple_select ->
        Enum.reduce_while(val, false, fn val, _ ->
          if val in choices do
            {:cont, false}
          else
            {:halt, true}
          end
        end)
    end

    # TODO: add an error to the field, instead of raising error

    if invalid do
      raise Field.Select.ValidationError,
        message: "The "<>inspect(val)<>" value for :"<>to_string(field.name)<>" is invalid. "<>
          "Possible values: "<>inspect(choices)
    end

    field
  end

end
