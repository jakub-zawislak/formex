defmodule Formex.CollectionCase do
  defmacro __using__(_) do
    quote do
      use Formex.TestCase
      import Formex.Builder
      alias Formex.TestModel.User
      alias Formex.TestModel.UserAddress
      alias Formex.TestModel.UserAccount
      alias Formex.TestRepo

      def insert_users() do
        TestRepo.insert(%User{first_name: "Grażyna", last_name: "Kowalska"})
        TestRepo.insert(%User{first_name: "Wiesio", last_name: "Nowak", user_addresses: [
          %UserAddress{street: "Mazurska", postal_code: "11-700", city: "Mrągowo"},
          %UserAddress{street: "Księżycowa", postal_code: "10-699", city: "Olsztyn"},
        ], schools: [
          %{id: "1dc5da4c-d4cd-4d4b-8167-5e8b61d53f7e", name: "Gimnazjum"},
          %{id: "b1902697-b577-44ae-bbd2-010c84eea0cc", name: "Liceum"}
        ], user_accounts: [
          %UserAccount{number: "number1"},
          %UserAccount{number: "number2"},
          %UserAccount{number: "number3"},
        ]})
        TestRepo.insert(%User{first_name: "Krystyna", last_name: "Pawłowicz"})
        TestRepo.insert(%User{first_name: "Jan", last_name: "Cebula"})
        TestRepo.insert(%User{first_name: "Przemek", last_name: "Cebula"})
      end

      def get_user(key) do
        User
        |> User.ordered
        |> TestRepo.all
        |> Enum.at(key)
        |> TestRepo.preload(user_addresses: UserAddress.ordered(UserAddress))
        |> TestRepo.preload(user_accounts: UserAccount.ordered(UserAccount))
      end
    end
  end
end
