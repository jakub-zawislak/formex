defmodule Formex.Repo.Migrations.ArticleCategory do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :category_id, references(:categories)
    end

    create index(:articles, [:category_id])
  end
end
