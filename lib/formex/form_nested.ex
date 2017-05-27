defmodule Formex.FormNested do
  @repo Application.get_env(:formex, :repo)
  alias __MODULE__
  alias Formex.Field
  alias Formex.Form

  defstruct form: nil,
    name: nil,
    validation: [],
    opts: []

  @type t :: %FormNested{}

  @doc """
  Creates a nested form.

  Example:

  ```
  form
  |> add(:user_info, :nested, type: App.UserInfoType, struct_module: App.UserInfo)
  ```

  ## Options

    * `type` - module that implements `Formex.Type`. Required
  """
  @spec create(form :: Form.t, type :: any, name :: Atom.t, opts :: Map.t) :: Form.t
  def create(form, type, name, opts) do
    substruct = Field.get_value(form, name)

    submodule = if form.struct_info[name] != :any do 
      form.struct_info[name]
    else
      Keyword.get(opts, :struct_module) || raise "the :struct_module option is required"
    end

    params  = form.params[to_string(name)] || %{}

    subform = Formex.Builder2.create_form(type, substruct, params, form.opts, submodule)
    item    = %FormNested{
      form: subform,
      name: name,
      validation: Keyword.get(opts, :validation, []),
      opts: opts
    }

    {form, item}
  end

end
