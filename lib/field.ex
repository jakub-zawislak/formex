defmodule Formex.Field do
  import Ecto.Query
  alias __MODULE__

  @doc """
  Defines the Formex.Field struct.

    * `:name` - a field name, for example: `:title`
    * `:type` - type of field that in most cases will be name of function from `Phoenix.HTML.Form`
    * `:value` - the value from struct/params
    * `:required` - is field required?
    * `:label` - the text label
    * `:data` - additional data used by particular field type (eg. `:select_assoc` stores here data
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

  @repo Application.get_env(:formex, :repo)

  @doc """
  Creates a new field.

  `type` is, in most cases, the name of function from `Phoenix.HTML.Form`. For now the only
  exception is the `:select_assoc`

  ## Custom types

    * `:select_assoc` - creates standard `:select`, but also downloads list of options from Repo.
      Example of use for Article with one Category:
      ```
      schema "articles" do
        belongs_to :category, App.Category
      end
      ```
      ```
      form
      |> add(:select_assoc, :category_id, label: "Category")
      ```
      Formex will find out that `:category_id` refers to App.Category schema and download all rows
      from Repo ordered by name. It assumes that Category has field called `name`

  ## Options

    * `:label`
    * `:required` - defaults to true
    * `:phoenix_opts` - options that will be passed to `Phoenix.HTML.Form`, for example:
      ```
      form
      |> add(:textarea, :content, phoenix_opts: [
        rows: 4
      ])
      ```
  """
  def create_field(form, :select_assoc, name, opts) do

    name_id = name
    name = Regex.replace(~r/_id$/, Atom.to_string(name_id), "") |> String.to_atom

    get_options = fn ->
      module = form.model.__schema__(:association, name).queryable

      query = from e in module,
        select: {e.name, e.id},
        order_by: e.name

      @repo.all(query)
    end

    %Field{
      name: name_id,
      type: :select,
      value: Map.get(form.struct, name),
      label: get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      data: [
        options: get_options.()
      ],
      opts: opts
    }

  end

  def create_field(form, type, name, opts) do

    %Field{
      name: name,
      type: type,
      value: Map.get(form.struct, name),
      label: get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      opts: opts
    }

  end

  #

  defp get_label(name, opts) do
    if opts[:label] do
      opts[:label]
    else
      Atom.to_string name
    end
  end

end
