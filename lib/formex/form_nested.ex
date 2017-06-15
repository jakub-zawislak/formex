defmodule Formex.FormNested do
  @repo Application.get_env(:formex, :repo)
  alias __MODULE__
  alias Formex.Field
  alias Formex.Form

  defstruct form: nil,
    name: nil,
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
  """
  
  @spec start_creating(form :: Form.t, type :: any, name :: Atom.t, opts :: Map.t) :: Form.t
  def start_creating(form, type, name, opts) do

    submodule = case form.struct_info[name] do 
      {:nested, submodule} -> submodule
      _ -> nil
    end

    submodule = if !submodule do 
      Keyword.get(opts, :struct_module) || raise "the :struct_module option is required"
    else
      submodule
    end

    %FormNested{
      name: name,
      struct_module: submodule,
      type: type,
      validation: Keyword.get(opts, :validation, []),
      opts: opts
    }
  end

  @spec finish_creating(form :: Form.t, form_nested :: FormNested.t) :: Form.t
  def finish_creating(form, form_nested) do
    %{type: type, name: name, struct_module: struct_module} = form_nested

    substruct = Field.get_value(form, name)

    params  = form.params[to_string(name)] || %{}

    subform = Formex.Builder2.create_form(type, substruct, params, form.opts, struct_module)

    form_nested
    |> Map.put(:form, subform)
  end

end
