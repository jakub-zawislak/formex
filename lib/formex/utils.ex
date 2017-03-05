defmodule Formex.Utils.Map do
  @moduledoc false

  def get_property(map, [key|tail]) do
    get_property Map.get(map, key), tail
  end

  def get_property(value, []) do
    value
  end

end

defmodule Formex.Utils do
  @moduledoc false

  def is_module(module) do
    :erlang.function_exported(module, :module_info, 0)
  end

end
