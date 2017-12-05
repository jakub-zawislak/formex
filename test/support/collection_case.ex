defmodule Formex.CollectionCase do
  defmacro __using__(_) do
    quote do
      use Formex.TestCase
      import Formex.Builder
      alias Formex.TestModel.User
      alias Formex.TestModel.UserAddress
      alias Formex.TestModel.UserAccount
      alias Formex.TestRepo

      def get_user(index) do
        [
          %User{first_name: "Grażyna", last_name: "Kowalska", user_addresses: [
            %UserAddress{
              id: 1, street: "Księżycowa", postal_code: "10-699", city: "Olsztyn", country_id: "1"
            },
          ]},
          %User{first_name: "Wiesio", last_name: "Nowak", user_addresses: [
            %UserAddress{
              id: 2, street: "Mazurska", postal_code: "11-700", city: "Mrągowo", country_id: "1"
            },
            %UserAddress{
              id: 1, street: "Księżycowa", postal_code: "10-699", city: "Olsztyn", country_id: "1"
            },
          ], user_accounts: [
            %UserAccount{id: 3, number: "number1"},
            %UserAccount{id: 7, number: "number2"},
            %UserAccount{id: 9, number: "number3"},
          ]},
          %User{first_name: "Krystyna", last_name: "Pawłowicz"},
          %User{first_name: "Jan", last_name: "Cebula"},
          %User{first_name: "Przemek", last_name: "Cebula"}
        ]
        |> Enum.at(index)
      end
    end
  end
end
