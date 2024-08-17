defmodule ElixirServer do
  use Application

  def start(_type, _args) do
    IO.puts("Starting the Elixir server...")

    ElixirServer.Supervisor.start_link()
  end
end
