defmodule Formex.BuilderType.Ecto do
  @moduledoc false
  defstruct [:form]
end

defimpl Formex.BuilderProtocol, for: Formex.BuilderType.Ecto do
  alias Formex.Form
  alias Formex.Field
  alias Formex.FormNested
  alias Formex.FormCollection

  @repo Application.get_env(:formex, :repo)

  @spec create_form(Map.t) :: Map.t
  def create_form(args) do
    form = args.form.type.build_form(args.form)

    form = form
    |> Map.put(:struct, preload_assocs(form))
    |> Form.finish_creating

    Map.put(args, :form, form)
  end

  @spec create_struct_info(Map.t) :: Map.t
  def create_struct_info(args) do
    form   = args.form
    struct = struct(form.struct_module)

    struct_info = struct
    |> Map.from_struct
    |> Enum.filter(&(elem(&1, 0) !== :__meta__))
    |> Enum.map(fn {k, v} ->
      v = case get_assoc_or_embed(form, k) do
        %{cardinality: :many, related: module} ->
          {:collection, module}

        %{cardinality: :one, related: module} ->
          {:nested, module}

        _ -> :any
      end

      {k, v}
    end)

    form = Map.put(form, :struct_info, struct_info)
    Map.put(args, :form, form)
  end

  #

  defp preload_assocs(form) do

    # trzeba zrobić jeszcze tworzenie nowego struct dla nested gdy jest pusty
    # albo obsłużyć fakt że jest pusty i nie wyświetlać forma

    form.items
    |> Enum.filter(fn item ->
      case item do
        %FormNested{}     -> true
        %FormCollection{} -> true
        %Field{}          -> item.type == :multiple_select
        _                 -> false
      end
    end)
    |> Enum.reduce(form.struct, fn item, struct ->
      if is_assoc(form, item.name) do
        struct
        |> @repo.preload(item.name)
      else
        struct
      end
    end)
  end

  @doc false
  @spec get_assoc_or_embed(form :: Form.t, name :: Atom.t) :: any
  defp get_assoc_or_embed(form, name) do
    if is_assoc(form, name) do
      form.struct_module.__schema__(:association, name)
    else
      form.struct_module.__schema__(:embed, name)
    end
  end

  @doc false
  @spec is_assoc(form :: Form.t, name :: Atom.t) :: boolean
  defp is_assoc(form, name) do
    form.struct_module.__schema__(:association, name) != nil
  end
end
