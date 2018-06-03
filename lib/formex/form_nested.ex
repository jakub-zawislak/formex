defmodule Formex.FormNested do
  alias __MODULE__
  alias Formex.Field
  alias Formex.Form

  defstruct form: nil,
            name: nil,
            # added only for compability with validation libs which look for `struct_name`
            struct_name: nil,
            struct_module: nil,
            type: nil,
            validation: [],
            opts: []

  @type t :: %FormNested{}

  @moduledoc """
  ```
  form
  |> add(:user_info, :nested, type: App.UserInfoType, struct_module: App.UserInfo)
  ```

  ## Options

    * `type` - module that implements `Formex.Type`. Required
    * `struct_module` - module of struct, e.g. `App.UserInfo`
  """

  @doc false
  @spec start_creating(form :: Form.t(), type :: any, name :: Atom.t(), opts :: Map.t()) :: Form.t()
  def start_creating(form, type, name, opts) do
    submodule =
      case form.struct_info[name] do
        {:nested, submodule} -> submodule
        _ -> nil
      end

    submodule =
      if submodule do
        submodule
      else
        Keyword.get(opts, :struct_module) || raise "the :struct_module option is required"
      end

    %FormNested{
      name: name,
      # struct_name: Keyword.get(opts, :struct_name, name), # not handled yet
      struct_name: name,
      struct_module: submodule,
      type: type,
      validation: Keyword.get(opts, :validation, []),
      opts: opts
    }
  end

  @doc false
  @spec finish_creating(form :: Form.t(), form_nested :: FormNested.t()) :: Form.t()
  def finish_creating(form, form_nested) do
    %{type: type, name: name, struct_module: struct_module} = form_nested

    substruct = Field.get_value(form, name)

    params = form.params[to_string(name)] || %{}

    substruct =
      if substruct do
        substruct
      else
        struct(struct_module)
      end

    subform = Formex.Builder.create_form(type, substruct, params, form.opts, struct_module)

    form_nested
    |> Map.put(:form, subform)
  end
end
