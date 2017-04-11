defmodule Formex.NestedCase do
  defmacro __using__(_) do
    quote do
      use Formex.TestCase
      import Formex.Builder
      alias Formex.TestModel.User
      alias Formex.TestModel.UserInfo
      alias Formex.TestRepo

      def insert_users() do
        TestRepo.insert(%User{first_name: "Grażyna", last_name: "Kowalska"})
        TestRepo.insert(%User{first_name: "Wiesio", last_name: "Nowak",
                              user_info: %UserInfo{section: "asd"}})
        TestRepo.insert(%User{first_name: "Krystyna", last_name: "Pawłowicz"})
        TestRepo.insert(%User{first_name: "Jan", last_name: "Cebula"})
        TestRepo.insert(%User{first_name: "Przemek", last_name: "Cebula"})
      end

      def get_first_user() do
        User
        |> User.ordered
        |> TestRepo.all
        |> Enum.at(0)
      end
    end
  end
end
