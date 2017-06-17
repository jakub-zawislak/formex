defmodule Formex.Ecto.Type do
  @moduledoc """
  Module that must be used in form types that uses Ecto.

  # Installation

  Just add `use Formex.Ecto.Type`

  # Example

  ```
  defmodule App.ArticleType do
    use Formex.Type
    use Formex.Ecto.Type

    def build_form(form) do
      form
      |> add(:title, :text_input, label: "Title")
      # ...
    end

    def changeset_after_create_callback(changeset, form) do
      # do something with changeset
      # since Formex 0.5, you cannot add errors to changeset
      changeset
    end
  ```
  """

  defmacro __using__([]) do
    quote do
      @behaviour Formex.Type
      import Formex.Type

      def changeset_after_create_callback(changeset, _form) do
        changeset
      end

      defoverridable [changeset_after_create_callback: 2]
    end
  end

  @doc """
  Callback that will be called after changeset creation.

  In this callback you can modify changeset.
  Since Formex 0.5, you cannot add errors to changeset.
  """
  @callback changeset_after_create_callback(changeset :: Ecto.Changeset.t, form :: Formex.Form.t)
    :: Ecto.Changeset.t

end