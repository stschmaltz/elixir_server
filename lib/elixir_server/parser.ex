defmodule ElixirServer.Parser do
  alias ElixirServer.Conversation

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %Conversation{method: method, path: path}
  end
end
