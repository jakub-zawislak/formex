defmodule App.Repo.Migrations.CreateUserInfo do
  use Ecto.Migration

  def change do
    create table(:user_infos) do
      add :section, :string

      timestamps()
    end

    alter table(:users) do
      add :user_info_id, references(:user_infos, on_delete: :nothing)
    end

    create index(:users, [:user_info_id])

  end
end
