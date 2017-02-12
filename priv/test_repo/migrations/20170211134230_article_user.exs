defmodule App.Repo.Migrations.ArticleUser do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :user_id, references(:users, on_delete: :nothing)
    end
  end
end
