defmodule Formex.TestErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  # use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  # def error_tag(form, field) do
  #   if error = form.errors[field] do
  #     content_tag :span, translate_error(error), class: "help-block"
  #   end
  # end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({_msg, _opts}) do
    "błond"
  end
end
