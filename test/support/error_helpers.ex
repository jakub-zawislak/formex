defmodule Formex.TestErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  # use Phoenix.HTML

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({_msg, _opts}) do
    "błond"
  end
end
