defmodule Formex.NestedCase do
  defmacro __using__(_) do
    quote do
      use Formex.TestCase
      import Formex.Builder
      alias Formex.TestModel.User
      alias Formex.TestModel.UserInfo
    end
  end
end
