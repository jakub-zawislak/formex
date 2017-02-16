defmodule Formex.View do
  use Phoenix.HTML
  alias Formex.Form

  @moduledoc """
  Helper functions for templating.

  Example of use:

      <%= formex_form_for @form, @action, fn f -> %>
        <%= if @form.changeset.action do %>
          <div class="alert alert-danger">
            <p>Oops, something went wrong! Please check the errors below.</p>
          </div>
        <% end %>

        <%= formex_rows f %>

        <div class="form-group">
          <%= submit "Submit", class: "btn btn-primary" %>
        </div>
      <% end %>

  """

  @doc """
  Works similar to a `Phoenix.HTML.Form.form_for/4`

  In the callback function the first argument is `t:Formex.Form.t/0` instead of a
  `t:Phoenix.HTML.Form.t/0`.
  This argument contains the `t:Phoenix.HTML.Form.t/0` under a `:phoenix_form` key
  """
  @spec formex_form_for(Form.t, String.t, Keyword.t (Formex.t -> Phoenix.HTML.unsafe))
                   :: Phoenix.HTML.safe
  def formex_form_for(form, action, options \\ [], fun) do

    phoenix_options = options
    |> Keyword.delete(:template)
    |> Keyword.delete(:template_options)

    Phoenix.HTML.Form.form_for(form.changeset, action, phoenix_options, fn f ->
      form
      |> Map.put(:phoenix_form, f)
      |> Map.put(:template, options[:template])
      |> Map.put(:template_options, options[:template_options])
      |> fun.()
    end)
  end

  @doc """
  Generates all `formex_row/2`s at once
  """
  @spec formex_rows(Form.t, Keyword.t) :: Phoenix.HTML.safe
  def formex_rows(form, options \\ []) do
     Enum.map(form.fields, fn field ->
       formex_row(form, field.name, options)
     end)
  end

  @doc """
  Generates a row. Example of use:

      <%= formex_row f, :title %>
      <%= formex_row f, :content %>
      <%= formex_row f, :category_id %>
  """
  @spec formex_row(Form.t, Atom.t, Keyword.t) :: Phoenix.HTML.safe
  def formex_row(form, field_name, options \\ []) do

    field            = Enum.find(form.fields, &(&1.name == field_name))
    template         = get_template(form, options)
    template_options = get_template_options(form, options)

    apply(template, :generate_row, [form, field, template_options])
  end

  defp get_template(form, row_options) do
    row_options[:template] 
      || form.template
      || Application.get_env(:formex, :template)
      || Formex.Template.BootstrapVertical
  end

  defp get_template_options(form, row_options) do
    []
    |> Keyword.merge(form.template_options || [])
    |> Keyword.merge(row_options[:template_options] || [])
  end

end
