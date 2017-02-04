defmodule Formex.CustomField do

  @moduledoc """
  A behaviour module for implementing the custom field.

  Check the source of
  [SelectAssoc](https://github.com/jakub-zawislak/formex/blob/master/lib/custom_fields/select_assoc.ex)
  for an example of use
  """

  @doc """
  Function that generates `t:Formex.Field.t/0`, similary to `Formex.Field.create_field/4`
  """
  @callback create_field(form :: Formex.Form.t, name :: atom, opts :: Map.t) :: Formex.Field.t

end
