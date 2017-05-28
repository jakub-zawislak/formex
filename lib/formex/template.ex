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
      alias Formex.Button

      @behaviour Formex.Template
    end
  end

  @doc false
  def helper do
    quote do
      use Phoenix.HTML
      alias Formex.Form
      alias Formex.Field
      alias Formex.Button
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
  @callback generate_input(form :: Form.t, field_or_button :: any) :: Phoenix.HTML.safe
  @callback generate_label(form :: Form.t, field :: Field.t, class :: String.t) :: Phoenix.HTML.safe

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_) do
    main()
    helper()
  end

  #

  @doc """
  Runs function from `Phoenix.HTML.Form` defined in a `Field.type` or `Button.type`
  """
  @spec render_phoenix_input(item :: any, args :: Keyword.t) :: any
  def render_phoenix_input(item, args) do
    apply(Phoenix.HTML.Form, item.type, args)
  end

  @doc """
  Returns list of errors
  """
  @spec get_errors(Form.t, Field.t) :: any
  def get_errors(form, field) do
    form.errors[field.name] || []
  end

  @doc """
  Checks if given field has an error
  """
  @spec has_error(Form.t, Field.t) :: any
  def has_error(form, field) do
    Enum.count(get_errors(form, field)) > 0
  end

  @doc """
  Adds a CSS class to the `:phoenix_opts` keyword
  """
  @spec add_class(phoenix_opts :: Keyword.t, class :: String.t) :: Keyword.t
  def add_class(phoenix_opts, class) do
    Keyword.merge(phoenix_opts, [class: class<>" "<>phoenix_opts[:class]])
  end

end
