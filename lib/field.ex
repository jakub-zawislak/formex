defmodule Formex.Field do
  alias __MODULE__

  @doc """
  Defines the Formex.Field struct.

    * `:name` - a field name, for example: `:title`
    * `:type` - a type of a field that in most cases will be the name of a function from `Phoenix.HTML.Form`
    * `:value` - the value from struct/params
    * `:required` - is field required?
    * `:label` - the text label
    * `:data` - additional data used by particular field type (eg. `:select` stores here data
      for `<option>`'s)
    * `:opts` - options
  """
  defstruct name: nil,
    # assoc: false,
    type: nil,
    value: nil,
    required: true,
    label: "",
    data: [],
    opts: []

  @type t :: %Field{}

  @doc """
  Creates a new field.

  `type` is the name of function from `Phoenix.HTML.Form`.

  ## Options

    * `:label`
    * `:required` - defaults to true. If set, it will be validated by the
      `Ecto.Changeset.validate_required/4`. Also, the template helper will use it to generate
      an additional `.required` CSS class.
    * `:choices` - list of `<option>`s for `:select` and `:multiple_select`
      ```
      form
      |> add(:select, :field, choices: ["Option 1": 1, "Options 2": 2])
      ```
    * `:phoenix_opts` - options that will be passed to `Phoenix.HTML.Form`, for example:
      ```
      form
      |> add(:textarea, :content, phoenix_opts: [
        rows: 4
      ])
      ```
  """
  def create_field(form, type, name, opts) do

    %Field{
      name: name,
      type: type,
      value: Map.get(form.struct, name),
      label: get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      data: [
        choices: opts[:choices]
      ],
      opts: opts
    }

  end

  @doc false
  def get_label(name, opts) do
    if opts[:label] do
      opts[:label]
    else
      Atom.to_string name
    end
  end

end
