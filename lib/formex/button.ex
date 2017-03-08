defmodule Formex.Button do
  alias __MODULE__
  alias Formex.Field

  @doc """
  Defines the Formex.Button struct.

    * `:name` - a field name. By default the same as `:type`
    * `:type` - a type of a field that in most cases will be the name of a function from `Phoenix.HTML.Form`
    * `:label` - the text label
    * `:opts` - options
  """
  defstruct name: nil,
    type: nil,
    label: "",
    opts: [],
    phoenix_opts: []

  @type t :: %Button{}

  @doc """
  Creates a new button.

  `type` is the name of function from `Phoenix.HTML.Form`. May be either `:submit` or `:reset`.

  Example:
  ```
  form
  |> add(:save, :submit, label: "Save it!", phoenix_opts: [
    class: "btn-primary"
  ])
  ```

  ```
  <%= formex_row f, :save %>
  ```
  """
  def create_button(type, name, opts \\ []) do
    %Button{
      name: name,
      type: type,
      label: Field.get_label(name, opts),
      opts: Field.prepare_opts(opts),
      phoenix_opts: Field.prepare_phoenix_opts(opts)
    }
  end

end
