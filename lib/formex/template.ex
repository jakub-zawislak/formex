defmodule Formex.Template do

  def main do
    quote do
      use Phoenix.HTML
      alias Formex.Form
      alias Formex.Field

      @behaviour Formex.Template
    end
  end

  def helper do
    quote do
      use Phoenix.HTML
      alias Formex.Form
      alias Formex.Field

      @spec render_phoenix_input(Atom.t, Keyword.t) :: any
      def render_phoenix_input(type, args) do
        apply(Phoenix.HTML.Form, type, args)
      end

      @spec translate_error(Form.t, Field.t) :: any
      def translate_error(form, field) do
        Application.get_env(:formex, :translate_error).(form.phoenix_form.errors[field.name])
      end

      @spec has_error(Form.t, Field.t) :: any
      def has_error(form, field) do
        form.phoenix_form.errors[field.name]
      end
    end
  end

  @callback generate_row(Form.t, Formex.Field.t, Keyword.t) :: any

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_) do
    main()
    helper()
  end

end
