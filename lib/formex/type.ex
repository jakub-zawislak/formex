defmodule Formex.Type do
  @repo Application.get_env(:formex, :repo)

  @moduledoc """
  In order to create a form, you need to create the Type file. It's similar to
  [Symfony's](https://symfony.com/doc/current/forms.html#creating-form-classes)
  way of creating forms.

  Example:

  ```
  defmodule App.ArticleType do
    use Formex.Type
    alias Formex.CustomField.SelectAssoc

    def build_form(form) do
      form
      |> add(:text_input, :title, label: "Title")
      |> add(:textarea, :content, label: "Content", phoenix_opts: [
        rows: 4
      ])
      |> add(:checkbox, :hidden, label: "Is hidden", required: false)
      |> add(SelectAssoc, :category_id, label: "Category", phoenix_opts: [
        prompt: "Choose category"
      ])
      |> add_button(:reset, "Reset form", phoenix_opts: [
        class: "btn-default"
      ])
      |> add_button(:submit, if(form.struct.id, do: "Edit", else: "Add"), phoenix_opts: [
        class: "btn-primary"
      ])
    end

    # optional
    def changeset_after_create_callback(changeset) do
      # do an extra validation
      changeset
    end
  end
  ```
  """

  defmacro __using__([]) do
    quote do
      @behaviour Formex.Type
      import Formex.Type

      def changeset_after_create_callback( changeset ) do
        changeset
      end

      defoverridable [changeset_after_create_callback: 1]
    end
  end

  @doc """
  Adds a field to the form.

  If the `type_or_module` is an atom, then this function invokes `Formex.Field.create_field/4`.
  Otherwise, the `c:Formex.CustomField.create_field/3` is called.
  """
  @spec add(form :: Form.t, type_or_module :: Atom.t, name :: Atom.t, opts :: Map.t) :: Form.t
  def add(form, type_or_module, name, opts \\ []) do

    field = if Formex.Utils.is_module(type_or_module) do
      type_or_module.create_field(form, name, opts)
    else
      Formex.Field.create_field(form, type_or_module, name, opts)
    end

    Formex.Form.put_item(form, field)
  end

  @doc """
  Adds a button to the form.

  The `type` may be either `:submit` or `:reset`.
  This function invokes `Formex.Button.create_button/3`.
  """
  @spec add_button(form :: Form.t, type :: Atom.t, label :: String.t, opts :: Map.t) :: Form.t
  def add_button(form, type, label, opts \\ []) do

    button = Formex.Button.create_button(type, label, opts)

    Formex.Form.put_item(form, button)
  end

  @doc """
  Embeds a form of assoc to the main form.

  If a struct of this form is not preloaded, it will be loaded.
  If it's a `one_to_one` association and the loaded struct is `nil`, a new struct will be created.
  """
  @spec add_form(form :: Form.t, type :: any, name :: Atom.t) :: Form.t
  def add_form(form, type, name) do

    sub_struct = Map.get(form.struct, name)

    {form, sub_struct} = if Ecto.assoc_loaded? sub_struct do
      {form, sub_struct}
    else
      struct     = @repo.preload(form.struct, name)
      sub_struct = Map.get(struct, name)

      sub_struct = if !is_nil(sub_struct) do
        sub_struct
      else
        sub_module = form.model.__schema__(:association, name).queryable
        struct(sub_module)
      end

      struct = Map.put(struct, name, sub_struct)
      form   = Map.put(form, :struct, struct)

      {form, sub_struct}
    end

    subform = Formex.Builder.create_form(type, sub_struct, form.params[to_string(name)] || %{})
    field   = Formex.Field.create_field(form, subform, name)

    Formex.Form.put_item(form, field)
  end

  @doc """
  In this callback you have to add fields to the form.
  """
  @callback build_form(form :: Formex.Form.t) :: Formex.Form.t

  @doc """
  Callback that will be called after changeset creation. In this function you can
  for example add an extra validation to your changeset.
  """
  @callback changeset_after_create_callback(changeset :: Ecto.Changeset.t) :: Ecto.Changeset.t

end
