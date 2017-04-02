defmodule App.Repo.Migrations.UserAddress do
  use Ecto.Migration

  def change do
    create table(:user_addresses) do
      add :city, :string
      add :postal_code, :string
      add :street, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_addresses, [:user_id])
  end
end
