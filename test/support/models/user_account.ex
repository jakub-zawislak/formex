defmodule Formex.TestModel.UserAccount do
  use Formex.TestModel

  schema "user_accounts" do
    field :number, :string
    field :removed, :boolean

    belongs_to :user, Formex.TestModel.User

    timestamps()
    formex_collection_child()
  end

  def ordered(query) do
    from c in query,
      order_by: c.id
  end

end
