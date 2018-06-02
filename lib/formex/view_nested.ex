defmodule Formex.View.Nested do
  import Formex.View

  @moduledoc """
  Helper functions for templating nested form.

  See [Type docs](https://hexdocs.pm/formex/Formex.Type.html#module-nested-forms)
  for example of use.
  """

  @doc false
  def formex_nested(form, item_name) do
    formex_nested(form, item_name, [], nil)
  end

  @doc false
  def formex_nested(form, item_name, fun) when is_function(fun) do
    formex_nested(form, item_name, [], fun)
  end

  @doc false
  def formex_nested(form, item_name, options) when is_list(options) do
    formex_nested(form, item_name, options, nil)
  end

  @doc """
  Generates a HTML for nested form

  Examples of use:

  * Standard
      ```
      <%= formex_nested f, :user_info %>
      ```
  * Set a form template for nested form
      ```
      <div class="form-horizontal">
        <%= formex_nested f, :user_info, template: Formex.Template.BootstrapHorizontal %>
      </div>
      ```
  * Use your render function
      ```
      <%= formex_nested f, :user_info, fn subform -> %>
        <%= formex_row subform, :section %>
        <%= formex_row subform, :organisation_cell %>
      <% end %>
      ```
  * Template and render function
      ```
      <div class="form-horizontal">
        <%= formex_nested f, :user_info, [template: Formex.Template.BootstrapHorizontal],
          fn subform -> %>
          <%= formex_row subform, :section %>
          <%= formex_row subform, :organisation_cell %>
        <% end %>
      </div>
      ```
  """
  def formex_nested(form, item_name, options \\ [], fun) do
    item = Enum.find(form.items, &(&1.name == item_name))
    template = Formex.View.get_template(form, options)
    template_options = Formex.View.get_template_options(form, options)

    if !item do
      throw("Key :" <> to_string(item_name) <> " not found in form " <> to_string(form.type))
    end

    fun = if !fun, do: &formex_rows(&1), else: fun

    Phoenix.HTML.Form.inputs_for(form.phoenix_form, item.name, fn f ->
      item.form
      |> Map.put(:phoenix_form, f)
      |> Map.put(:template, template)
      |> Map.put(:template_options, template_options)
      |> (fn f ->
            html =
              if !fun do
                formex_rows(f)
              else
                fun.(f)
              end

            id_field = Phoenix.HTML.Form.hidden_input(f.phoenix_form, :id)

            [html, id_field]
          end).()
    end)
  end
end
