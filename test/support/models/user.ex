defmodule Formex.TestModel.User do
  use Formex.TestModel

  schema "users" do
    field :first_name, :string
    field :last_name, :string

    belongs_to :department, Formex.TestModel.Department
    belongs_to :user_info, Formex.TestModel.UserInfo
    has_many   :user_addresses, Formex.TestModel.UserAddress

    embeds_many :schools, School do
      field :name, :string
      formex_collection_child()
    end

    timestamps()
  end

  def ordered(query) do
    from c in query,
      order_by: c.id
  end

end
