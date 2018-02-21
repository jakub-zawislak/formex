defmodule Formex.Controller do
  alias Formex.Form
  alias Formex.Builder

  defmacro __using__(_) do
    quote do
      import Formex.Builder
      import Formex.Controller
    end
  end

  @moduledoc """
  Helpers for controller. Imports `Formex.Builder`. Probably you are looking for
  `Formex.Builder.create_form/5`.

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

  ```
  def new(conn, _params) do
    form = create_form(App.ArticleType, %Article{})
    render(conn, "form.html", form: form)
  end
  ```

  ```
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

  For usage with Ecto see `Formex.Ecto.Controller`
  """

  @doc """
  Validates form. When is valid, returns `{:ok, form.new_struct}`, otherwise, `{:error, form}` with
  validation errors inside `form.errors`
  """
  @spec handle_form(Form.t) :: {:ok, Map.t} | {:error, Form.t}
  def handle_form(form) do
    form = Builder.handle_submit(form)

    if form.valid? do
      {:ok, form.new_struct}
    else
      {:error, %{form | submitted?: true}}
    end
  end

end
