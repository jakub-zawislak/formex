defmodule Formex.TestCase do
  use ExUnit.CaseTemplate
  alias Formex.TestRepo

  setup do
    # Explicitly get a connection before each test
    # By default the test is wrapped in a transaction
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)

    # The :shared mode allows a process to share
    # its connection with any other process automatically
    Ecto.Adapters.SQL.Sandbox.mode(TestRepo, { :shared, self() })
  end
end
