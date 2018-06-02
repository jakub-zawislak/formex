defprotocol Formex.BuilderProtocol do
  @spec create_struct_info(Map.t()) :: Map.t()
  def create_struct_info(args)

  @spec create_form(Map.t()) :: Map.t()
  def create_form(args)
end

defmodule Formex.BuilderType.Struct do
  @moduledoc false
  defstruct [:form]
end

defmodule Formex.Builder do
  alias Formex.Form
  alias Formex.BuilderProtocol
  alias Formex.FormCollection
  alias Formex.FormNested
  alias Formex.Field
  alias Formex.Field.Select
  alias Formex.Validator

  # for those who want to know how `create_form` function knows is it normal struct or Ecto schema
  # when you call `use Formex.Ecto.Schema` in `web/web.ex`, in every model is created
  # `formex_wrapper` function, which returns wrapper module.
  # `Formex.BuilderProtocol` is implemented for this wrapper
  @spec create_form(module, struct, Map.t(), Keyword.t(), module) :: Form.t()
  def create_form(type, struct, params \\ %{}, opts \\ [], struct_module \\ nil) do
    struct_module = if(struct_module, do: struct_module, else: struct.__struct__)

    wrapper =
      if struct_module.module_info(:exports)[:formex_wrapper] do
        struct_module.formex_wrapper
      else
        Formex.BuilderType.Struct
      end

    form = %Form{
      type: type,
      struct: struct,
      struct_module: struct_module,
      params: params,
      opts: opts
    }

    struct(wrapper, form: form)
    |> BuilderProtocol.create_struct_info()
    |> BuilderProtocol.create_form()
    |> Map.get(:form)
    |> map_params()
    |> apply_params()
    |> handle_selects_on_create()
  end

  # Called from controller, only on the main form
  @spec handle_submit(Form.t()) :: Form.t()
  def handle_submit(form) do
    form
    |> handle_selects_on_submit()
    |> Validator.validate()
  end

  #

  defp map_params(form = %{params: params}) when params == %{} do
    Map.put(form, :mapped_params, params)
  end

  defp map_params(form) do
    params = form.params

    new_params =
      form
      |> Form.get_fields_controllable()
      |> Enum.reduce(%{}, fn item, new_params ->
        key = item.name |> to_string
        val = params[key]

        {new_name, new_val} =
          case item do
            collection = %FormCollection{} ->
              items =
                Enum.map(collection.forms, fn nested ->
                  map_params(nested.form).mapped_params
                end)

              subparams =
                Range.new(0, Enum.count(items) - 1)
                |> Enum.zip(items)
                |> Enum.map(fn {key, item} -> {to_string(key), item} end)
                |> Enum.into(%{})

              {key, subparams}

            nested = %FormNested{} ->
              {key, map_params(nested.form).mapped_params}

            field ->
              new_val =
                if val !== nil do
                  val
                else
                  case field.type do
                    :multiple_select ->
                      []

                    :select ->
                      nil

                    _ ->
                      ""
                  end
                end

              {item.struct_name |> to_string, new_val}
          end

        new_params = Map.put(new_params, new_name, new_val)

        to_remove = Form.get_items_with_changed_name(form)

        new_params =
          Map.merge(params, new_params)
          |> Enum.filter(fn {key, value} ->
            String.to_atom(key) not in to_remove
          end)
          |> Map.new()
      end)

    Map.put(form, :mapped_params, new_params)
  end

  # Could be done better. In this case it applies params and creates a :new_struct only for the
  # main form. :form's that are in FormNested and FormCollection are not touched
  # in objective programming it would be easier :D
  # Anyway, the FormNested and FormCollections also applies this function to their subforms
  @spec apply_params(form :: Form.t()) :: Form.t()
  defp apply_params(form) do
    %{struct: struct, mapped_params: params} = form

    struct =
      Enum.reduce(params, struct, fn {key, val}, struct ->
        key = String.to_atom(key)

        struct
        |> Map.update!(key, fn _old_val ->
          case Form.find(form, key) do
            collection = %FormCollection{} ->
              Enum.map(collection.forms, fn nested ->
                apply_params(nested.form).new_struct
              end)

            nested = %FormNested{} ->
              apply_params(nested.form).new_struct

            _ ->
              val
          end
        end)
      end)

    Map.put(form, :new_struct, struct)
  end

  @spec handle_selects_on_create(form :: Form.t()) :: Form.t()
  defp handle_selects_on_create(form) do
    form
    |> Form.modify_selects_recursively(fn form_of_field, field ->
      val = Map.get(form_of_field.struct, field.struct_name)

      field
      |> Select.handle_select_without_choices(val)
    end)
  end

  @spec handle_selects_on_submit(form :: Form.t()) :: Form.t()
  defp handle_selects_on_submit(form) do
    form
    |> Form.modify_selects_recursively(fn form_of_field, field ->
      val = Map.get(form_of_field.new_struct, field.struct_name)

      field
      |> Select.handle_select_without_choices(val)
      |> Select.validate(val)
    end)
  end
end

defimpl Formex.BuilderProtocol, for: Formex.BuilderType.Struct do
  alias Formex.Form

  @spec create_form(Map.t()) :: Map.t()
  def create_form(args) do
    form =
      args.form.type.build_form(args.form)
      |> Form.finish_creating()

    Map.put(args, :form, form)
  end

  # collects info about struct fields data types
  @spec create_struct_info(Map.t()) :: Map.t()
  def create_struct_info(args) do
    form = args.form
    struct = struct(form.struct_module)

    struct_info =
      struct
      |> Map.from_struct()
      |> Enum.filter(&(elem(&1, 0) !== :__meta__))
      |> Enum.map(fn {k, v} ->
        v = if is_list(v), do: {:collection, nil}, else: :any
        {k, v}
      end)

    form = Map.put(form, :struct_info, struct_info)
    Map.put(args, :form, form)
  end
end
