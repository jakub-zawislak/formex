defmodule Formex.Controller do
  alias Formex.Form
  @repo Application.get_env(:formex, :repo)

  defmacro __using__(_) do
    quote do
      import Formex.Builder
      import Formex.Controller
    end
  end

  @moduledoc """
  Helpers for controller. Imports `Formex.Builder`.

  # Installation:

  `web/web.ex`
  ```
  def controller do
    quote do
      use Formex.Controller
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

  ## Usage without a database

  ```
  defmodule App.Registration do
    use App.Web, :model

    embedded_schema do # instead of `schema`
      field :email
      field :password
    end
  end
  ```

  ```
  def register(conn, %{"registration" => registration_params}) do
    RegistrationType
    |> create_form(%Registration{}, registration_params)
    |> handle_form
    |> case do
      {:ok, registration} ->
        # do something with the `registration`
      {:error, form} ->
        # display errors
        render(conn, "index.html", form: form)
    end
  end
  ```
  """

  @doc """
  Works similar to `insert_form_data/1` and `update_form_data/1`, but doesn't require a database.
  Should be used with `embedded_schema`.
  """
  @spec handle_form(Form.t) :: {:ok, Ecto.Schema.t} | {:error, Form.t}
  def handle_form(form) do
    # if form.changeset.valid? do
    #   {:ok, Ecto.Changeset.apply_changes(form.changeset)}
    # else
    #   changeset = %{form.changeset | action: :update}
    #   {:error, Map.put(form, :changeset, changeset)}
    # end

    # if form.changeset.valid? do
      {:ok, form.struct}
      {:error, form}
    # else
    #   changeset = %{form.changeset | action: :update}
    #   {:error, Map.put(form, :changeset, changeset)}
    # end
  end

  @doc """
  Invokes `Repo.insert`. In case of `:error`, returns `{:error, form}` (with new `form.changeset`
  value) instead of `{:error, changeset}` (as Ecto does)
  """
  @spec insert_form_data(Form.t) :: {:ok, Ecto.Schema.t} | {:error, Form.t}
  def insert_form_data(form) do
    case @repo.insert(form.changeset) do
      {:ok, schema}       -> {:ok, schema}
      {:error, changeset} -> {:error, Map.put(form, :changeset, changeset)}
    end
  end

  @doc """
  Invokes `Repo.update`. In case of `:error`, returns `{:error, form}` (with new `form.changeset`
  value) instead of `{:error, changeset}` (as Ecto does)
  """
  @spec update_form_data(Form.t) :: {:ok, Ecto.Schema.t} | {:error, Form.t}
  def update_form_data(form) do
    case @repo.update(form.changeset) do
      {:ok, schema}       -> {:ok, schema}
      {:error, changeset} -> {:error, Map.put(form, :changeset, changeset)}
    end
  end

end
