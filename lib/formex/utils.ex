defmodule Formex.Utils.Map do
  @moduledoc false

  def get_property(map, [key | tail]) do
    get_property(Map.get(map, key), tail)
  end

  def get_property(value, []) do
    value
  end
end

defmodule Formex.Utils do
  @moduledoc false

  def module?(module) do
    Code.ensure_loaded?(module)
  end

  def implements?(module, behaviour) do
    Enum.member?(module.module_info[:attributes][:behaviour], behaviour)
  end
end
