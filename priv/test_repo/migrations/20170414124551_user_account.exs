defmodule App.Repo.Migrations.UserAccount do
  use Ecto.Migration

  def change do
    create table(:user_accounts) do
      add :number, :string
      add :removed, :boolean
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_accounts, [:user_id])
  end
end
