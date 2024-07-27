defmodule ElixirServer.Handler do
  def handle(request) do
    request
    |> parse
    |> log
    |> route
    |> format_response
  end

  def log(conversation), do: IO.inspect(conversation)

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, resp_body: "", status: nil}
  end

  def route(conversation) do
    route(conversation, conversation.method, conversation.path)
  end

  def route(conversation, "GET", "/wildthings") do
    %{conversation | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(conversation, "GET", "/bears") do
    %{conversation | resp_body: "Teddy, Smokey, Paddington", status: 200}
  end

  def route(conversation, "GET", "/bears" <> id) do
    %{conversation | resp_body: "Bear #{id}", status: 200}
  end

  def route(conversation, _method, _path) do
    %{conversation | resp_body: "Route not found", status: 404}
  end

  def format_response(conversation) do
    # TODO: Use values in the map to create an HTTP response string:
    """
    HTTP/1.1 #{conversation.status} #{status_reason(conversation.status)}
    Content-Type: text/html
    Content-Length: #{conversation.resp_body |> String.length()}

    #{conversation.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = ElixirServer.Handler.handle(request)

IO.puts(response)

request = """
GET /butts HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = ElixirServer.Handler.handle(request)

IO.puts(response)

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = ElixirServer.Handler.handle(request)

IO.puts(response)
