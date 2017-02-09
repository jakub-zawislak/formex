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

    * `choice_label` - controls the content of `<option>`. May be the name of a field or a function.
      Example of use:

      ```
      form
      |> add(SelectAssoc, :article_id, label: "Article", choice_label: :title)
      ```
      ```
      form
      |> add(SelectAssoc, :user_id, label: "User", choice_label: fn user ->
        user.first_name<>" "<>user.last_name
      end)
      ```

    * `query` - an additional query that filters the choices list. Example of use:

      ```
      form
      |> add(SelectAssoc, :user_id, query: fn query ->
        from e in query,
          where: e.fired == false
      end)
      ```
  """

  def create_field(form, name_id, opts) do

    name = Regex.replace(~r/_id$/, Atom.to_string(name_id), "") |> String.to_atom

    module = form.model.__schema__(:association, name).queryable

    choices = module
    |> apply_query(opts[:query])
    |> get_choices(opts[:choice_label])

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

  defp apply_query(query, custom_query) when is_function(custom_query) do
    custom_query.(query)
  end

  defp apply_query(query, _)do
    query
  end

  defp get_choices(module, choice_label) when is_function(choice_label) do

    module
    |> @repo.all
    |> Enum.map(fn row ->
      name = choice_label.(row)
      {name, row.id}
    end)
    |> Enum.sort(fn {name1, _}, {name2, _} ->
      name1 < name2
    end)

  end

  defp get_choices(module, choice_label) do

    choice_label = if choice_label, do: choice_label, else: :name

    query = from e in module,
      select: {field(e, ^choice_label), e.id},
      order_by: field(e, ^choice_label)

    @repo.all(query)

  end

end
