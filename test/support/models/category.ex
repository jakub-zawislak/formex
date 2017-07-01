# defmodule Formex.TestModel.Category do
#   use Formex.TestModel

#   schema "categories" do
#     field :name, :string

#     timestamps()
#   end
# end

defmodule Formex.TestModel.Category do
  defstruct [:id, :name]
end