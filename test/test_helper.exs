alias Formex.TestRepo

ExUnit.start()

{:ok, _pid} = TestRepo.start_link
Ecto.Adapters.SQL.Sandbox.mode(TestRepo, { :shared, self() })

# TestRepo.start_link
# Ecto.Adapters.SQL.Sandbox.mode(TestRepo, :manual)
