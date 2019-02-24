# Formex

Formex is an extensible form library for Phoenix.
With this library you don't write changeset (as in Ecto), but a separate module that declares
fields of form
(like in [Symfony](https://symfony.com/doc/current/forms.html#creating-form-classes)).

You can also use it with Ecto - see [formex_ecto](https://github.com/jakub-zawislak/formex_ecto).
That library will build changeset and additional Ecto queries for itself.

Formex doesn't validate data for itself - it uses
[validation libraries](https://hexdocs.pm/formex/Formex.Validator.html#available-adapters) instead.

Formex comes with helper functions for templating. For now there is only a Bootstrap 3 form
template, but you can easily create your own templates.

## TL;DR

<img src="http://i.imgur.com/YIG0R2P.png" width="800px">

## Installation
In addition to the main library, you have to install some validator adapter.
In this example we will use Vex.
[List of available adapters](https://hexdocs.pm/formex/Formex.Validator.html#available-adapters)

`mix.exs`
```elixir
def deps do
  [{:formex, "~> 0.6.0"},
   {:formex_vex, "~> 0.1.0"}]
end

def application do
  [applications: [:formex]]
end
```

`config/config.exs`
```elixir
config :formex,
  validator: Formex.Validator.Vex,
  translate_error: &AppWeb.ErrorHelpers.translate_error/1,  # optional, from /lib/app_web/views/error_helpers.ex
  template: Formex.Template.BootstrapHorizontal,            # optional, can be overridden in a template
  template_options: [                                       # optional, can be overridden in a template
    left_column: "col-sm-2",
    right_column: "col-sm-10"
  ]
```

`web/web.ex`
```elixir
def controller do
  quote do
    use Formex.Controller
  end
end

def view do
  quote do
    use Formex.View
  end
end
```

## Usage

Let's create a form for article.

### Model

```elixir
# /web/model/article.ex
defmodule App.Article do
  defstruct [:title, :content, :hidden]
end
```

### Form Type

```elixir
# /web/form/article_type.ex
defmodule App.ArticleType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:title, :text_input, label: "Title", validation: [presence: true])
    |> add(:content, :textarea, label: "Content", phoenix_opts: [
      rows: 4
    ], validation: [presence: true])
    |> add(:hidden, :checkbox, label: "Is hidden?", required: false)
    |> add(:save, :submit, label: "Submit", phoenix_opts: [
      class: "btn-primary"
    ])
  end
end
```

Please note that `required` option is used only to generate an asterisk.
Any validation must be done via `validation` option.

The `:text_input` and so on are function names from
[`Phoenix.HTML.Form`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html)

### Controller

```elixir
def new(conn, _params) do
  form = create_form(App.ArticleType, %Article{})
  render(conn, "form.html", form: form)
end

def create(conn, %{"article" => article_params}) do
  App.ArticleType
  |> create_form(%Article{}, article_params)
  |> handle_form
  |> case do
    {:ok, article} ->
      # do something with a new article struct
    {:error, form} ->
      # display errors
      render(conn, "form.html", form: form)
  end
end
```

### Template

`form.html.eex`
```elixir
<%= formex_form_for @form, article_path(@conn, :create), [class: "form-horizontal"], fn f -> %>
  <%= if @form.submitted? do %>Oops, something went wrong!<% end %>

  <%= formex_row f, :title %>
  <%= formex_row f, :content %>
  <%= formex_row f, :hidden %>
  <%= formex_row f, :save %>

  <%# or generate all fields at once: formex_rows f %>
<% end %>
```

Put an asterisk to required fields:
```css
.required .control-label:after {
  content: '*';
  margin-left: 3px;
}
```

The final effect after submit:

<img src="http://i.imgur.com/GwFzMjl.png" width="511px">

# Documentation

[https://hexdocs.pm/formex](https://hexdocs.pm/formex)

### Basic usage
* [Creating forms](https://hexdocs.pm/formex/Formex.Type.html)
* [Usage in a controller](https://hexdocs.pm/formex/Formex.Controller.html)
* [Usage in a template](https://hexdocs.pm/formex/Formex.View.html)
* [Validation](https://hexdocs.pm/formex/Formex.Validator.html)
* [Nested forms](https://hexdocs.pm/formex/Formex.Type.html#module-nested-forms)
* [Collections of forms](https://hexdocs.pm/formex/Formex.Type.html#module-collections-of-forms)

### Custom fields
* [Creating a custom field](https://hexdocs.pm/formex/Formex.CustomField.html)

### Templating
* [Changing a template](https://hexdocs.pm/formex/Formex.View.html#module-changing-a-form-template)
* [Creating own template](https://hexdocs.pm/formex/Formex.Template.html)
* [Bootstrap Vertical](https://hexdocs.pm/formex/Formex.Template.BootstrapVertical.html)
* [Bootstrap Horizontal](https://hexdocs.pm/formex/Formex.Template.BootstrapHorizontal.html)

### Guides
* [Add new items to collection on the backend](https://hexdocs.pm/formex/guides.html#add-new-items-to-collection-on-the-backend)
* [Using a select picker plugin with ajax search](https://hexdocs.pm/formex/guides.html#using-a-select-picker-plugin-with-ajax-search)
* [Uploading files with Arc.Ecto](https://hexdocs.pm/formex_ecto/guides.html#uploading-files-with-arc-ecto) (Formex.Ecto)


# Extensions

* [formex_ecto](https://github.com/jakub-zawislak/formex_ecto) - Ecto integration

# Validation adapters

* [formex_vex](https://github.com/jakub-zawislak/formex_vex) - Vex
* [formex_ecto](https://github.com/jakub-zawislak/formex_ecto) - Ecto.Changeset
