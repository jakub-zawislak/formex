defmodule Formex.CollectionCase do
  defmacro __using__(_) do
    quote do
      use Formex.TestCase
      import Formex.Builder
      alias Formex.TestModel.User
      alias Formex.TestModel.UserAddress
      alias Formex.TestRepo

      def insert_users() do
        TestRepo.insert(%User{first_name: "Grażyna", last_name: "Kowalska"})
        TestRepo.insert(%User{first_name: "Wiesio", last_name: "Nowak", user_addresses: [
          %UserAddress{street: "Mazurska", postal_code: "11-700", city: "Mrągowo"},
          %UserAddress{street: "Księżycowa", postal_code: "10-699", city: "Olsztyn"},
        ]})
        TestRepo.insert(%User{first_name: "Krystyna", last_name: "Pawłowicz"})
        TestRepo.insert(%User{first_name: "Jan", last_name: "Cebula"})
        TestRepo.insert(%User{first_name: "Przemek", last_name: "Cebula"})
      end
    end
  end
end
