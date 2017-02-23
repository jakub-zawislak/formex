defmodule App.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string

      timestamps()
    end

    create table(:articles_tags, primary_key: false) do
      add :article_id, references(:articles)
      add :tag_id, references(:tags)
    end
  end
end
