defmodule Formex.TestModel.UserInfo do
  use Formex.TestModel

  schema "user_infos" do
    field :section, :string

    has_one :user, Formex.TestModel.User

    timestamps()
  end

end
