defmodule Formex.TestModelEmbedded.User do
  use Formex.TestModel

  embedded_schema do
    field :first_name, :string
    field :last_name, :string

    embeds_one :user_info, Info do
      field :section
    end

    embeds_many :user_addresses, Address do
      field :street
      field :postal_code
      field :city
      formex_collection_child()
    end
  end

end
