# defmodule Formex.TestModel.User do
#   use Formex.TestModel

#   schema "users" do
#     field :first_name, :string
#     field :last_name, :string

#     belongs_to :department, Formex.TestModel.Department
#     belongs_to :user_info, Formex.TestModel.UserInfo
#     has_many   :user_addresses, Formex.TestModel.UserAddress
#     has_many   :user_accounts, Formex.TestModel.UserAccount

#     timestamps()
#   end

#   def ordered(query) do
#     from c in query,
#       order_by: c.id
#   end

# end

defmodule Formex.TestModel.User do
  defstruct [
    :id,
    :first_name,
    :last_name,
    :department_id,
    user_info: %Formex.TestModel.UserInfo{},
    user_accounts: [],
    user_addresses: []
  ]
end
