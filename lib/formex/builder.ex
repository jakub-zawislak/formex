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

defmodule Formex.Builder2 do
  alias Formex.Form
  alias Formex.BuilderProtocol
  alias Formex.FormCollection
  alias Formex.FormNested

  @spec create_form(module, struct, Map.t, List.t, module) :: Form.t
  def create_form(type, struct, params \\ %{}, opts \\ [], struct_module \\ nil) do

    struct_module = if(struct_module, do: struct_module, else: struct.__struct__)

    wrapper = if struct_module.module_info(:exports)[:formex_wrapper] do
      struct_module.wrapper
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

  # not kosher :D should be written with recursion
  @spec apply_params(form :: Form.t) :: Form.t
  defp apply_params(form) do
    %{struct: struct, params: params, struct_info: struct_info} = form

    struct = Enum.reduce(params, struct, fn {key, val}, struct ->
      key = String.to_atom(key)

      struct
      |> Map.update!(key, fn _old_val ->
        case Form.find(form, key) do
          collection = %FormCollection{} ->
            
            Enum.map(val, fn {_sub_key, sub_val} ->

              sub_struct = collection.struct_module |> struct
              
              Enum.reduce(sub_val, sub_struct, fn {sub_sub_key, sub_sub_val}, sub_struct ->
                sub_sub_key = String.to_atom(sub_sub_key)

                sub_struct
                |> Map.put(sub_sub_key, sub_sub_val)
              end)
            end)

          nested = %FormNested{} ->
            Enum.reduce(val, struct, fn {sub_key, sub_val}, struct ->
              sub_key = String.to_atom(sub_key)

              struct
              |> Map.put(sub_key, sub_val)
            end)

          _ ->
            val
        end
      end)
    end)

    Map.put(form, :struct, struct)
  end
end

defimpl Formex.BuilderProtocol, for: Formex.BuilderType.Struct do
  alias Formex.Form

  @spec create_form(Map.t) :: Map.t
  def create_form(args) do
    form = args.form.type.build_form(args.form)

    Map.put(args, :form, form)
  end

  @spec create_struct_info(Map.t) :: Map.t
  def create_struct_info(args) do
    form   = args.form
    struct = struct(form.struct_module)

    struct_info = struct
    |> Map.from_struct
    |> Enum.map(fn {k, v} -> 
      v = if is_list(v), do: :collection, else: :any
      {k, v}
    end)

    form = Map.put(form, :struct_info, struct_info)
    Map.put(args, :form, form)
  end
end

defmodule Formex.Builder do
  import Ecto.Changeset
  import Ecto.Query
  alias Formex.Form
  alias Formex.FormCollection

  @repo Application.get_env(:formex, :repo)

  @moduledoc """
  The form builder to be used in a controller. Imported by `Formex.Controller`.

  Example:

  ```
  form = create_form(App.ArticleType, %Article{})
  render(conn, "new.html", form: form)
  ```
  """

  @doc """
  Creates a form struct.

  ## Arguments

    * `type` - the module that implements `Formex.Type` behaviour, for example: `App.ArticleType`
    * `struct` - the struct that will be used in `Ecto.Changeset.cast/3`, for example:
      `%App.Article{}`
    * `params` - the parameters that will be used in `Ecto.Changeset.cast/3`
    * `opts` - some additional data. Accessible by `form.opts`. Example:

        Set current logged user
        ```
        form = create_form(TransferType, %Transfer{}, %{}, user: user)
        ```
        
        Filter select options that belongs to this user
        ```
        def build_form(form) do
          form
          |> add(:user_account_id, SelectAssoc, query: fn query ->
              query
              |> Account.by_user(form.opts[:user])
            end
        end
        ```

    * `model` - optional Ecto model in case if `struct` is nil. Used by `Formex.FormexCollection` 
      and `Formex.FormNested`
  """
  @spec create_form(module, Ecto.Schema.t, Map.t, List.t, module) :: Form.t
  def create_form(type, struct, params \\ %{}, opts \\ [], struct_module \\ nil) do

    form = %Form{
      type: type,
      struct: struct,
      struct_module: if(struct_module, do: struct_module, else: struct.__struct__),
      params: params,
      opts: opts
    }
    |> type.build_form()

    form
    |> Map.put(:struct, preload_assocs(form))
    |> create_changeset(type)
  end

  #

  defp preload_assocs(form) do
    form
    |> Form.get_fields
    |> Enum.filter(&(&1.type == :multiple_select))
    |> Enum.reduce(form.struct, fn field, struct ->
      @repo.preload(struct, field.name)
    end)
  end

  #

  defp create_changeset(form, type) do
    struct = if form.struct, do: form.struct, else: struct(form.struct_module)

    changeset = struct
    |> cast(form.params, get_normal_fields_names(form))
    |> cast_multiple_selects(form)
    |> cast_embedded_forms(form)
    |> validate_required(get_required_fields_names(form))
    |> validate_selects(form)
    |> type.changeset_after_create_callback

    form
    |> Map.put(:changeset, changeset)
  end

  defp cast_multiple_selects(changeset, form) do
    Form.get_fields(form)
    |> Enum.filter(&(&1.type == :multiple_select))
    |> Enum.reduce(changeset, fn field, changeset ->
      module = form.struct_module.__schema__(:association, field.name).related
      ids    = form.params[to_string(field.name)] || []

      associated = module
      |> where([c], c.id in ^ids)
      |> @repo.all
      |> Enum.map(&Ecto.Changeset.change/1)

      changeset
      |> put_assoc(field.name, associated)
    end)
  end

  defp cast_embedded_forms(changeset, form) do
    Form.get_subforms(form)
    |> Enum.reduce(changeset, fn item, changeset ->

      cast_func = if Form.is_assoc(form, item.name) do
        &cast_assoc/3
      else
        &cast_embed/3
      end

      case item do
        %Formex.FormNested{} ->
          changeset
          |> cast_func.(item.name, required: item.required, with: fn _substruct, _params ->
            subform = item.form
            create_changeset(subform, subform.type).changeset
          end)

        %Formex.FormCollection{} ->
          changeset
          |> cast_func.(item.name, required: item.required, with: fn substruct, params ->

            substruct = if !substruct.id do
              Map.put(substruct, :formex_id, params["formex_id"])
            else
              substruct
            end

            item
            |> FormCollection.get_subform_by_struct(substruct)
            |> case do
              nil -> cast(substruct, %{}, [])

              nested_form ->
                subform = nested_form.form
    
                changeset = create_changeset(subform, subform.type).changeset
                |> cast(subform.params, [item.delete_field])

                if get_change(changeset, :formex_delete) do
                  %{changeset | action: :delete}
                else
                  changeset
                end
            end
          end)
      end
    end)
  end

  #

  defp get_normal_fields_names(form) do
    Form.get_fields(form)
    |> filter_normal_fields(form)
    |> Enum.map(&(&1.name))
  end

  defp get_required_fields_names(form) do
    Form.get_fields(form)
    |> Enum.filter(&(&1.required))
    |> filter_normal_fields(form)
    |> Enum.map(&(&1.name))
  end

  # It will find only many_to_many and one_to_many associations (not many_to_one),
  # because the names (field.name) of many_to_one assocs ends with "_id". This is ok
  defp filter_normal_fields(items, form) do
    items
    |> Enum.filter(fn field ->
      form.struct_module.__schema__(:association, field.name) == nil
    end)
  end

  @spec validate_selects(changeset :: Changeset.t, form :: Form.t) :: Changeset.t
  defp validate_selects(changeset, form) do
    form
    |> Form.get_fields
    |> Enum.filter(&(&1.type == :select))
    |> Enum.filter(&(changeset.changes[&1.name] != nil))
    |> Enum.reduce(changeset, fn (field, changeset) ->

      value_exists = Enum.find(field.data[:choices], fn {_, id} ->
        changeset.changes[field.name] == id
      end)

      if value_exists do
        changeset
      else
        add_error(changeset, field.name, "is invalid")
      end
    end)
  end

end
