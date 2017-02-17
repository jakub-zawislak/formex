defmodule Formex.Controller do

  defmacro __using__(_) do
    quote do
      import Formex.Builder
      import Formex.Repo
    end
  end

  # use Formex.Builder
  # use Formex.Repo

  @moduledoc """
  Module that imports `Formex.Builder` and `Formex.Repo`.

  Usage:

  `web/web.ex`
  ```
  def controller do
    quote do
      use Formex.Controller
    end
  end
  ```

  Usage inside a controller:

  ```
  def new(conn, _params) do
    form = create_form(App.ArticleType, %Article{})
    render(conn, "new.html", form: form)
  end
  ```

  ```
  def create(conn, %{"article" => article_params}) do
    App.ArticleType
    |> create_form(%Article{}, article_params)
    |> insert_form_data
    |> case do
      {:ok, _article} ->
        # ...
      {:error, form} ->
        # ...
    end
  end
  ```

  ```
  def edit(conn, %{"id" => id}) do
    article = Repo.get!(Article, id)
    form = create_form(App.ArticleType, article)
    render(conn, "edit.html", article: article, form: form)
  end
  ```

  ```
  def update(conn, %{"id" => id, "article" => article_params}) do
    article = Repo.get!(Article, id)

    App.ArticleType
    |> create_form(article, article_params)
    |> update_form_data
    |> case do
      {:ok, article} ->
        # ...
      {:error, form} ->
        # ...
    end
  end
  ```
  """

end
