defmodule Formex.Schema do
  require Ecto.Schema

  defmacro __using__([]) do
    quote do
      import Formex.Schema
    end
  end

  defmacro formex_collection_child do
    quote do
      Ecto.Schema.field(:formex_delete, :boolean, virtual: true)
    end
  end

end
