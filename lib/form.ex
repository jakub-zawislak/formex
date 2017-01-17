defmodule Formex.Form do

  defstruct type: nil,
    struct: nil,
    model: nil,
    fields: [],
    params: %{},
    changeset: nil,
    phoenix_form: nil

end
