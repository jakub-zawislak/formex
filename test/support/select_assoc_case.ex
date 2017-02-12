defmodule Formex.SelectAssocCase do
  defmacro __using__(_) do
    quote do
      use Formex.TestCase
      import Formex.Builder
      alias Formex.TestModel.Article
      alias Formex.TestModel.Category
      alias Formex.TestModel.User
      alias Formex.TestModel.Department
      alias Formex.TestRepo

      def insert_categories() do
        TestRepo.insert(%Category{name: "asd"})
        TestRepo.insert(%Category{name: "bcd"})
        TestRepo.insert(%Category{name: "cfg"})
      end

      def insert_users() do
        dep1 = TestRepo.insert!(%Department{name: "Administration"})
        dep2 = TestRepo.insert!(%Department{name: "Sales"})
        dep3 = TestRepo.insert!(%Department{name: "Accounting"})

        TestRepo.insert(%User{department_id: dep3.id, first_name: "Grażyna", last_name: "Kowalska"})
        TestRepo.insert(%User{department_id: dep1.id, first_name: "Wiesio", last_name: "Nowak"})
        TestRepo.insert(%User{department_id: dep3.id, first_name: "Krystyna", last_name: "Pawłowicz"})
        TestRepo.insert(%User{department_id: dep1.id, first_name: "Jan", last_name: "Cebula"})
        TestRepo.insert(%User{department_id: dep2.id, first_name: "Przemek", last_name: "Cebula"})
      end
    end
  end
end
