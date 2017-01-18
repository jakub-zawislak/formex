defmodule Formex.Field do

  defstruct name: nil,
    assoc: false,
    type: nil,
    value: nil,
    required: true,
    label: "",
    data: [],
    opts: []

end
