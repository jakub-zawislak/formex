defmodule Formex.CustomField.SelectAssoc do
  @behaviour Formex.CustomField
  import Ecto.Query
  alias Formex.Field

  @repo Application.get_env(:formex, :repo)

  @moduledoc """
    This module generates a `:select` field with options downloaded from Repo.

    Example of use for Article with one Category:
    ```
    schema "articles" do
      belongs_to :category, App.Category
    end
    ```
    ```
    form
    |> add(Formex.CustomField.SelectAssoc, :category_id, label: "Category")
    ```
    Formex will find out that `:category_id` refers to App.Category schema and download all rows
    from Repo ordered by name. It assumes that Category has a field called `name`
  """

  def create_field(form, name_id, opts) do

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
      label: Field.get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      data: [
        options: get_options.()
      ],
      opts: opts
    }

  end

end
