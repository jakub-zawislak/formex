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
  from Repo ordered by name.

  ## Options

    * `choice_name` - controls the content of `<option>`. May be the name of field or function.
      Example of use:

      ```
      form
      |> add(SelectAssoc, :article_id, label: "Article", choice_name: :title)
      ```
      ```
      form
      |> add(SelectAssoc, :article_id, label: "Article", choice_name: fn article ->
        article.title
      end)
      ```
  """

  def create_field(form, name_id, opts) do

    name = Regex.replace(~r/_id$/, Atom.to_string(name_id), "") |> String.to_atom

    # option_name

    module = form.model.__schema__(:association, name).queryable

    choices = get_choices(module, opts[:choice_name])

    %Field{
      name: name_id,
      type: :select,
      value: Map.get(form.struct, name),
      label: Field.get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      data: [
        choices: choices
      ],
      opts: opts
    }

  end

  defp get_choices(module, choice_name) when is_function(choice_name) do

    module
    |> @repo.all
    |> Enum.map(fn row ->
      name = choice_name.(row)
      {name, row.id}
    end)
    |> Enum.sort(fn {name1, _}, {name2, _} ->
      name1 < name2
    end)

  end

  defp get_choices(module, choice_name) do

    choice_name = if choice_name, do: choice_name, else: :name

    query = from e in module,
      select: {field(e, ^choice_name), e.id},
      order_by: field(e, ^choice_name)

    @repo.all(query)

  end

end
