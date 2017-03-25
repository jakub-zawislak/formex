defmodule Formex.TestModel do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use Formex.Schema

      import Ecto
      import Ecto.Query
    end
  end
end
