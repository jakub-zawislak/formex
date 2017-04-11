defmodule App.Repo.Migrations.UserSchool do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :schools, :map
    end
  end
end
