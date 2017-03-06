defmodule Formex.TestModel.User do
  use Formex.TestModel

  schema "users" do
    field :first_name, :string
    field :last_name, :string

    belongs_to :department, Formex.TestModel.Department
    belongs_to :user_info, Formex.TestModel.UserInfo

    timestamps()
  end

end
