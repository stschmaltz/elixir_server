defmodule ElixirServer.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def is_hibernating?(%{hibernating: true}), do: true

  def order_by_name(a, b) do
    a.name < b.name
  end
end
