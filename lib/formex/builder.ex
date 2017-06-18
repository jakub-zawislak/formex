defprotocol Formex.BuilderProtocol do
  @spec create_struct_info(Map.t) :: Map.t
  def create_struct_info(args)

  @spec create_form(Map.t) :: Map.t
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

  @spec create_form(module, struct, Map.t, List.t, module) :: Form.t
  def create_form(type, struct, params \\ %{}, opts \\ [], struct_module \\ nil) do

    struct_module = if(struct_module, do: struct_module, else: struct.__struct__)

    wrapper = if struct_module.module_info(:exports)[:formex_wrapper] do
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
    |> apply_params()
  end

  # Could be done better. In this case it applies params and creates a :new_struct only for the
  # main form. :form's that are in FormNested and FormCollection are not touched
  # in objective programming it would be easier :D
  @spec apply_params(form :: Form.t) :: Form.t
  defp apply_params(form) do
    %{struct: struct, params: params, struct_info: struct_info} = form

    struct = Enum.reduce(params, struct, fn {key, val}, struct ->
      key = String.to_atom(key)

      struct
      |> Map.update!(key, fn _old_val ->
        case Form.find(form, key) do
          collection = %FormCollection{} ->
            Enum.map(collection.forms, fn nested ->
              apply_params(nested.form).struct
            end)

          nested = %FormNested{} ->
            apply_params(nested.form).struct

          field = %Field{} ->
            validate_select(field, val)
            val

          _ -> val
        end
      end)
    end)

    Map.put(form, :new_struct, struct)
  end

  @spec validate_select(field :: Field.t, val :: String.t) :: nil
  defp validate_select(field, val) do
    case field.type do
      x when x in [:select, :multiple_select] ->
        choices = Enum.map(field.data[:choices], &(&1 |> elem(1) |> to_string))

        case field.type do
          :select ->
            String.length(val) > 0 && !(val in choices)
          :multiple_select ->
            Enum.reduce_while(val, false, fn val, _ ->
              if val in choices do
                {:cont, false}
              else
                {:halt, true}
              end
            end)
        end
        |> if do
          raise "The "<>inspect(val)<>" value for :"<>to_string(field.name)<>" is invalid. "<>
            "Possible values: "<>inspect(choices)
        end

      _ -> nil
    end
  end
end

defimpl Formex.BuilderProtocol, for: Formex.BuilderType.Struct do
  alias Formex.Form

  @spec create_form(Map.t) :: Map.t
  def create_form(args) do
    form = args.form.type.build_form(args.form)
    |> Form.finish_creating

    Map.put(args, :form, form)
  end

  # collects info about struct fields data types
  @spec create_struct_info(Map.t) :: Map.t
  def create_struct_info(args) do
    form   = args.form
    struct = struct(form.struct_module)

    struct_info = struct
    |> Map.from_struct
    |> Enum.filter(&(elem(&1, 0) !== :__meta__))
    |> Enum.map(fn {k, v} ->
      v = if is_list(v), do: {:collection, nil}, else: :any
      {k, v}
    end)

    form = Map.put(form, :struct_info, struct_info)
    Map.put(args, :form, form)
  end
end
