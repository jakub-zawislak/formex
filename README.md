# Formex

Formex is an abstract layer that helps to build forms in Phoenix and Ecto. With this library you
don't write changesets, but create form module with list of fields
(like in [Symfony](https://symfony.com/doc/current/forms.html#creating-form-classes)).
Formex will build changeset and additional Ecto queries for itself.
Formex also comes with helper functions for templating.

## Installation
`mix.exs`
```elixir
def deps do
  [{:formex, "~> 0.1.0"}]
end
```

`config.exs`
```elixir
config :formex,
  repo: App.Repo,
  translate_error: &App.ErrorHelpers.translate_error/1
```

## Usage

We have models Article and Category:

```elixir
schema "articles" do
  field :name, :string
  field :content, :string
  field :hidden, :boolean

  belongs_to :category, App.Category
end
```

```elixir
schema "categories" do
  field :title, :string
end
```

Let's create a form for Article:
```elixir
# /web/form/article_form.ex
defmodule App.ArticleForm do
  use Formex.Form

  def build_form( form ) do
    form
    |> add(:text_input, :title, label: "Title")
    |> add(:textarea, :content, label: "Content", phoenix_opts: [
      rows: 4
    ])
    |> add(:checkbox, :hidden, label: "Is hidden", required: false)
    |> add(:select_assoc, :category_id, label: "Category", phoenix_opts: [
      prompt: "Choose category"
    ])
  end
end
```

Form usage inside a controller:
```elixir
def create(conn, %{"article" => article_params}) do
  App.ArticleForm
  |> create_form(%Article{}, article_params)
  |> insert_form_data
  |> case do
    {:ok, _article} ->
      conn
      |> put_flash(:info, "Article created successfully.")
      |> redirect(to: article_path(conn, :index))
    {:error, form} ->
      render(conn, "new.html", form: form)
  end
end
```

Inside a template:
```html+eex
<%= formex_for @form, @action, fn f -> %>

  <%= if @form.changeset.action do %>
    <div class="alert alert-danger">
      <p>Oops, something went wrong! Please check the errors below.</p>
    </div>
  <% end %>

  <%= form_row f, :name %>
  <%= form_row f, :content %>
  <%= form_row f, :category_id %>

  <div class="form-group">
    <%= submit "Submit", class: "btn btn-primary" %>
  </div>

<% end %>
```

It's very simple, isn't it?
You don't need to create any changeset, nor write query to get options for a Category select.

## Advanced

If you need to change something in changeset, there is a callback for that:

```elixir
defmodule App.ArticleForm do
  # ...

  def build_form( form ) do
    # ...
  end

  def changeset_after_create_callback( changeset ) do
    # modify changeset and return it
    changeset
  end
end
```

## Documentation

[https://hexdocs.pm/formex](https://hexdocs.pm/formex).
