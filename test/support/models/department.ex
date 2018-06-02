# defmodule Formex.TestModel.Department do
#   use Formex.TestModel

#   schema "departments" do
#     field :name, :string

#     timestamps()
#   end

# end

defmodule Formex.TestModel.Department do
  defstruct [:id, :name]
end
