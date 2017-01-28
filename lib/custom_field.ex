defmodule Formex.CustomField do

  @moduledoc """
  Module used in custom fields

  Check `Formex.CustomField.SelectAssoc` for example of use
  """

  @doc """
  Function that generates `t:Formex.Field.t/0`, similary to `Formex.Field.create_field/4`
  """
  @callback create_field(form :: Formex.Form.t, name :: atom, opts :: Map.t) :: Formex.Field.t

end
