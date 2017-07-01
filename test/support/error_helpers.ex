defmodule Formex.TestErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  # use Phoenix.HTML

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, _opts}) do
    msg
  end
end
