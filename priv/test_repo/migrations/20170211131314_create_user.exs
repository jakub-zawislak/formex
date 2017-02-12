defmodule App.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :department_id, references(:departments, on_delete: :nothing)

      timestamps()
    end
    create index(:users, [:department_id])

  end
end
