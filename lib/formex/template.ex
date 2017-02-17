defmodule Formex.Template do
  alias Formex.Form
  alias Formex.Field

  @moduledoc """
  Use this module to create a custom form template.

  Usage:

  ```
  defmodule App.FormTemplate.SemanticUI do
    use Formex.Template

    def generate_row(form, field, _options \\\\ []) do
      # code that produces a Phoenix.HTML.safe
      # you can use here render_phoenix_input/2, translate_error/2, has_error/2
    end
  end
  ```

  If you want to create a several version of template (for example vertical and horizontal, as is
  already done with Bootstrap), you can move a common code to another module.

  Example:

  ```
  defmodule App.FormTemplate.SemanticUIVertical do
    use Formex.Template, :main # note the :main argument
    import App.FormTemplate.SemanticUI

    def generate_row(form, field, _options \\\\ []) do
      # code that produces a Phoenix.HTML.safe
    end
  end
  ```

  ```
  defmodule App.FormTemplate.SemanticUIHorizontal do
    use Formex.Template, :main # note the :main argument
    import App.FormTemplate.SemanticUI

    def generate_row(form, field, _options \\\\ []) do
      # code that produces a Phoenix.HTML.safe
    end
  end
  ```

  ```
  defmodule App.FormTemplate.SemanticUI do
    use Formex.Template, :helper # note the :helper argument

    # a common code for both versions
    # you can use here render_phoenix_input/2, translate_error/2, has_error/2
  end
  ```

  Check the source code of
  [templates](https://github.com/jakub-zawislak/formex/tree/master/lib/templates)
  for more examples.
  """

  @doc false
  def main do
    quote do
      use Phoenix.HTML
      alias Formex.Form
      alias Formex.Field

      @behaviour Formex.Template
    end
  end

  @doc false
  def helper do
    quote do
      use Phoenix.HTML
      alias Formex.Form
      alias Formex.Field
      import Formex.Template
    end
  end

  @doc """
  Generates a HTML for a field.

  ## Arguments
    * `options` - any options that you want to use inside a form template. It can be set by
      `:template_options` inside a `Formex.View` functions, or in the `:formex` config.
      For example, `Formex.Template.BootstrapHorizontal` uses options that stores columns sizes.
  """
  @callback generate_row(form :: Form.t, field :: Formex.Field.t, options :: Keyword.t) :: Phoenix.HTML.safe

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_) do
    main()
    helper()
  end

  #

  @doc """
  Runs function from `Phoenix.HTML.Form` defined in a `field.type`
  """
  @spec render_phoenix_input(Field.t, Keyword.t) :: any
  def render_phoenix_input(field, args) do
    apply(Phoenix.HTML.Form, field.type, args)
  end

  @doc """
  Translates error using function set in `:formex` config
  """
  @spec translate_error(Form.t, Field.t) :: any
  def translate_error(form, field) do
    Application.get_env(:formex, :translate_error).(form.phoenix_form.errors[field.name])
  end

  @doc """
  Checks if given field has a changeset error
  """
  @spec has_error(Form.t, Field.t) :: any
  def has_error(form, field) do
    form.phoenix_form.errors[field.name]
  end

end
