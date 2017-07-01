# defmodule Formex.TestModel.UserAddress do
#   use Formex.TestModel

#   schema "user_addresses" do
#     field :street, :string
#     field :postal_code, :string
#     field :city, :string

#     belongs_to :user, Formex.TestModel.User

#     timestamps()
#     formex_collection_child()
#   end

#   def ordered(query) do
#     from c in query,
#       order_by: c.id
#   end
# end

defmodule Formex.TestModel.UserAddress do
  defstruct [:id, :street, :postal_code, :city, :user_id, :formex_id, :formex_delete]
end