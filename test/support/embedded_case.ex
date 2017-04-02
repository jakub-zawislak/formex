defmodule Formex.EmbeddedCase do
  defmacro __using__(_) do
    quote do
      use Formex.TestCase
      import Formex.Builder
      alias Formex.TestModelEmbedded.User
    end
  end
end
