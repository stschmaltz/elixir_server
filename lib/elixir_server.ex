defmodule ElixirServer do
  def hello(name) do
    "Hello #{name}"
  end
end

IO.puts ElixirServer.hello("world")
