defmodule Formex.Ecto.Controller do
  alias Formex.Form
  alias Formex.Validator
  import Formex.Ecto.Changeset
  @repo Application.get_env(:formex, :repo)

  defmacro __using__(_) do
    quote do
      import Formex.Ecto.Controller
    end
  end

  @moduledoc """
  Ecto helpers for controller.

  # Installation:

  `web/web.ex`
  ```
  def controller do
    quote do
      use Formex.Ecto.Controller
    end
  end
  ```

  # Usage

  ## CRUD

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

  @doc """
  Works same as `Formex.Controller.handle_form`, but also invokes `Ecto.Repo.insert/2`
  """
  @spec insert_form_data(Form.t) :: {:ok, Ecto.Schema.t} | {:error, Form.t}
  def insert_form_data(form) do
    form = form |> Validator.validate()

    if form.valid? do
      form
      |> create_changeset
      |> @repo.insert
      |> case do
        {:error, changeset} ->
          raise_changeset_error(form, changeset)
        {:ok, struct} -> {:ok, struct}
      end
    else
      {:error, form}
    end
  end

  @doc """
  Works same as `Formex.Controller.handle_form`, but also invokes `Ecto.Repo.update/2`
  """
  @spec update_form_data(Form.t) :: {:ok, Ecto.Schema.t} | {:error, Form.t}
  def update_form_data(form) do
    form = form |> Validator.validate()

    if form.valid? do
      form
      |> create_changeset
      |> @repo.update
      |> case do
        {:error, changeset} ->
          raise_changeset_error(form, changeset)
        {:ok, struct} -> {:ok, struct}
      end
    else
      {:error, form}
    end
  end

  defp raise_changeset_error(form, changeset) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)

    if errors != %{} do
      raise "Your changeset has errors. Since Formex 0.5, errors added in
      `Type.changeset_after_create_callback` are not being validated. You have to use
      new validator functionality. Found errors:\n
      "<>inspect(errors)
    end

    {:error, form}
  end

end
