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
  Creates a new field.

  `type` is the name of function from `Phoenix.HTML.Form`.

  ## Options

    * `:name` - optional name of button
      For example: if you added a button this way

      ```
      form
      |> add_button(:submit, "Save")
      ```

      you can access it in the template by calling:
      ```
      <%= formex_row f, :submit %>
      ```

      But if you will pass the `:name` option

      ```
      form
      |> add_button(:submit, "Save", name: :special_submit)
      ```

      you can access it by this name:
      ```
      <%= formex_row f, :special_submit %>
      ```
  """
  def create_button(form, type, label, opts \\ []) do
    %Button{
      name: get_name(type, opts),
      type: type,
      label: label,
      opts: Field.prepare_opts(opts),
      phoenix_opts: Field.prepare_phoenix_opts(opts)
    }
  end

  defp get_name(type, opts) do
    if opts[:name] do
      opts[:opts]
    else
      type
    end
  end

end
