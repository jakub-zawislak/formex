defmodule Formex.Ecto.Schema do
  require Ecto.Schema

  defmacro __using__([]) do
    quote do
      import Formex.Ecto.Schema

      def formex_wrapper, do: Formex.BuilderType.Ecto
    end
  end

  defmacro formex_collection_child do
    quote do
      Ecto.Schema.field(:formex_delete, :boolean, virtual: true)
      Ecto.Schema.field(:formex_id, :string, virtual: true)
    end
  end

end
