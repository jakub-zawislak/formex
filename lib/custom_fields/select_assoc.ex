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
  |> add(:category_id, Formex.CustomField.SelectAssoc, label: "Category")
  ```
  Formex will find out that `:category_id` refers to App.Category schema and download all rows
  from Repo ordered by name.

  ## Options

    * `choice_label` - controls the content of `<option>`. May be the name of a field or a function.
      Example of use:

      ```
      form
      |> add(:article_id, SelectAssoc, label: "Article", choice_label: :title)
      ```
      ```
      form
      |> add(:user_id, SelectAssoc, label: "User", choice_label: fn user ->
        user.first_name<>" "<>user.last_name
      end)
      ```

    * `query` - an additional query that filters the choices list. Example of use:

      ```
      form
      |> add(:user_id, SelectAssoc, query: fn query ->
        from e in query,
          where: e.fired == false
      end)
      ```

    * `group_by` - wraps `<option>`'s in `<optgroup>`'s. May be `:field_name`,
      `:assoc_name` or `[:assoc_name, :field_name]`

      Example of use:

      ```
      schema "users" do
        field :first_name, :string
        field :last_name, :string
        belongs_to :department, App.Department
      end
      ```

      ```
      schema "departments" do
        field :name, :string
        field :description, :string
      end
      ```

      Group by last name of user:
      ```
      form
      |> add(:user_id, SelectAssoc, group_by: :last_name)
      ```

      Group by department, by `:name` (default) field:
      ```
      form
      |> add(:user_id, SelectAssoc, group_by: :department)
      ```

      Group by department, but by another field
      ```
      form
      |> add(:user_id, SelectAssoc, group_by: [:department, :description])
      ```
  """

  def create_field(form, name, opts) do
    if form.model.__schema__(:association, name) == nil do
      create_field_single(form, name, opts)
    else
      create_field_multiple(form, name, opts)
    end
  end

  defp create_field_single(form, name_id, opts) do
    name = Regex.replace(~r/_id$/, Atom.to_string(name_id), "")
    |> String.to_atom

    module  = form.model.__schema__(:association, name).related
    opts    = parse_opts(module, opts)
    choices = get_choices(module, opts)

    %Field{
      name: name_id,
      type: :select,
      value: Field.get_value(form, name),
      label: Field.get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      data: [
        choices: choices
      ],
      opts: Field.prepare_opts(opts),
      phoenix_opts: Field.prepare_phoenix_opts(opts)
    }
  end

  defp create_field_multiple(form, name, opts) do
    module  = form.model.__schema__(:association, name).related
    opts    = parse_opts(module, opts)
    choices = get_choices(module, opts)

    selected = if form.struct.id do
      form.struct
      |> @repo.preload(name)
      |> Map.get(name)
      |> Enum.map(&(&1.id))
    else
      []
    end

    %Field{
      name: name,
      type: :multiple_select,
      value: Field.get_value(form, name),
      label: Field.get_label(name, opts),
      required: Keyword.get(opts, :required, true),
      data: [
        choices: choices
      ],
      opts: Field.prepare_opts(opts),
      phoenix_opts: Keyword.merge(
        Field.prepare_phoenix_opts(opts),
        selected: selected
      )
    }
  end

  defp get_choices(module, opts) do
    module
    |> apply_query(opts[:query])
    |> apply_group_by_assoc(opts[:group_by])
    |> @repo.all
    |> group_rows(opts[:group_by])
    |> generate_choices(opts[:choice_label])
  end

  defp parse_opts(module, opts) do
    opts
    |> Keyword.update(:group_by, nil, fn(property_path) ->

      cond do
        is_list(property_path) -> property_path
        is_atom(property_path) ->
          cond do
            module.__schema__(:association, property_path) -> [property_path, :name]
            true -> [property_path]
          end
        true -> nil
      end

    end)
  end

  defp apply_query(query, custom_query) when is_function(custom_query) do
    custom_query.(query)
  end

  defp apply_query(query, _) do query end

  defp apply_group_by_assoc(query, [assoc|t]) do
    if Enum.count(t) > 0 do
      from(query, preload: [^assoc])
    else
      query
    end
  end

  defp apply_group_by_assoc(query, _) do query end

  defp group_rows(rows, property_path) when is_list(property_path) do
    rows
    |> Enum.group_by(&(Formex.Utils.Map.get_property(&1, property_path)))
  end

  defp group_rows(rows, _) do rows end

  defp generate_choices(rows, choice_label) when is_list(rows) do
    rows
    |> Enum.map(fn row ->
      label = cond do
        is_function(choice_label) ->
          choice_label.(row)
        !is_nil(choice_label) ->
          Map.get(row, choice_label)
        true ->
          row.name
      end

      {label, row.id}
    end)
    |> Enum.sort(fn {name1, _}, {name2, _} ->
      name1 < name2
    end)
  end

  defp generate_choices(grouped_rows, choice_label) when is_map(grouped_rows) do
    grouped_rows
    |> Enum.map(fn {group_label, rows} ->
      {group_label, generate_choices(rows, choice_label)}
    end)
    |> Map.new(&(&1))
  end

end
