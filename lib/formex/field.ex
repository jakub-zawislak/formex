defmodule Formex.Field do
  alias __MODULE__

  @doc """
  Defines the Formex.Field struct.

    * `:name` - a field name, for example: `:title`
    * `:struct_name` - a name of a key in your struct. By default the same as `:name`
    * `:custom_value` - custom function that extracts a value that will be used in view
    * `:type` - a type of a field that in most cases will be the name of a function from
      [`Phoenix.HTML.Form`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html)
    * `:value` - the value from struct/params
    * `:required` - is field required? Used only in template, not validated
    * `:validation` - validation rules to be passed to a validator
    * `:label` - the text label
    * `:data` - additional data used by particular field type (eg. `:select` stores here data
      for `<option>`'s)
    * `:opts` - options
    * `:phoenix_opts` - options that will be passed to
      [`Phoenix.HTML.Form`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html)
  """
  defstruct name: nil,
            struct_name: nil,
            custom_value: nil,
            type: nil,
            required: true,
            validation: [],
            label: "",
            data: [],
            opts: [],
            phoenix_opts: []

  @type t :: %Field{}

  @doc """
  Creates a new field.

  `type` is the name of function from
  [`Phoenix.HTML.Form`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html). For example,
  if you need to render a password field, then use
  [`Phoenix.HTML.Form.password_input/3`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#password_input/3)
  in that way:

  ```
  form
  |> add(:pass, :password_input)
  ```

  ## Options

    * `:label`
    * `:required` - defaults to true. Used only by the template helper to generate an additional
    `.required` CSS class.
    * `:struct_name` - a name of a key in your struct. Defaults to the `name` variable
    * `:custom_value` - use this, if you need to change value that will be used in view.
      For example, field of `Money.Ecto.Type` type casted to string returns a formatted number,
      when we may need a raw number. In this case we should use:
      ```
      form
      |> add(:money, :text_input, custom_value: fn value ->
        if value do
          value.amount
        end
      end)
      ```
    * `:phoenix_opts` - options that will be passed to
      [`Phoenix.HTML.Form`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html), for example:
      ```
      form
      |> add(:content, :textarea, phoenix_opts: [
        rows: 4
      ])
      ```

  ## Options for `<select>`

    * `:choices` - list of `<option>`s. Named "choices", not "options", because we don't want to
      confuse it with the rest of options
        ```
        form
        |> add(:field, :select, choices: ["Option 1": 1, "Options 2": 2])
        ```
        ```
        form
        |> add(:country, :select, choices: [
          "Europe": ["UK": 1, "Sweden": 2, "Poland": 3],
          "Asia": [...]
        ])
        ```
    * `:without_choices` - set this option to true if you want to render select without
      any `<option>`s and provide them in another way (for example, using
      [Ajax-Bootstrap-Select](https://github.com/truckingsim/Ajax-Bootstrap-Select)).

      It disables choices rendering in `Formex.Ecto.CustomField.SelectAssoc`.
    * `:choice_label_provider` - used along with `:select_without_choices`.

      When form is sent but it's displayed again (because of some errors), we have to render
      <select>` with a single `<option>`, previously chosen by user.

      This option expects a function that receives id and returns some label.

        ```
        form
        |> add(:customer, :select, without_choices: true, choice_label_provider: fn id ->
          Repo.get(Customer, id).name
        end)
        ```
      `Formex.Ecto.CustomField.SelectAssoc` will set this option for you
  """
  def create_field(type, name, opts \\ []) do
    data = []

    {opts, data} =
      if type in [:select, :multiple_select] do
        opts =
          opts
          |> Keyword.put_new(:without_choices, false)

        data =
          data
          |> Keyword.merge(choices: Keyword.get(opts, :choices, []))

        {opts, data}
      else
        {opts, []}
      end

    %Field{
      name: name,
      struct_name: Keyword.get(opts, :struct_name, name),
      custom_value: Keyword.get(opts, :custom_value),
      type: type,
      label: get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      validation: Keyword.get(opts, :validation, []),
      data: data,
      opts: prepare_opts(opts),
      phoenix_opts: prepare_phoenix_opts(opts)
    }
  end

  @doc false
  def get_label(name, opts) do
    if opts[:label] do
      opts[:label]
    else
      Atom.to_string(name)
    end
  end

  @doc false
  def get_value(form, name) do
    if form.struct do
      Map.get(form.struct, name)
    else
      nil
    end
  end

  @doc false
  def prepare_opts(opts) do
    opts
    |> Keyword.delete(:phoenix_opts)
    |> Keyword.delete(:custom_value)
  end

  @doc false
  def prepare_phoenix_opts(opts) do
    phoenix_opts = if opts[:phoenix_opts], do: opts[:phoenix_opts], else: []

    if phoenix_opts[:class] do
      phoenix_opts
    else
      Keyword.put(phoenix_opts, :class, "")
    end
  end
end
