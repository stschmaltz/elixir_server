defmodule ElixirServer.Parser do
  alias ElixirServer.Conversation

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] =
      request_line
      |> String.split(" ")

    params = parse_params(params_string)

    %Conversation{method: method, path: path, params: params}
  end

  defp parse_params(params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end
end
