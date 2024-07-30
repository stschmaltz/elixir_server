defmodule ElixirServer.Handler do
  def handle(request) do
    request
    |> parse
    |> log
    |> rewrite_path
    |> route
    |> track
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

  def rewrite_path(%{path: "/wildlife"} = conversation) do
    %{conversation | path: "/wildthings"}
  end

  def rewrite_path(conversation) do
    conversation
  end

  def route(%{method: "GET", path: "/wildthings"} = conversation) do
    %{conversation | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%{method: "GET", path: "/bears"} = conversation) do
    %{conversation | resp_body: "Teddy, Smokey, Paddington", status: 200}
  end

  def route(%{method: "GET", path: "/bears" <> id} = conversation) do
    %{conversation | resp_body: "Bear #{id}", status: 200}
  end

  def route(%{method: "GET", path: "/about"} = conversation) do
    file =
      Path.expand("../../pages", __DIR__)
      |> Path.join("about.html")
      |> File.read()
      |> handle_file(conversation)
  end

  def handle_file({:ok, contents}, conversation) do
    %{conversation | resp_body: contents, status: 200}
  end

  def handle_file({:error, :enoent}, conversation) do
    %{conversation | resp_body: "File not found", status: 404}
  end

  def handle_file({:error, reason}, conversation) do
    %{conversation | resp_body: "File error #{reason}", status: 500}
  end

  def route(%{path: path} = conversation) do
    %{conversation | resp_body: "Route not found", status: 404}
  end

  def track(%{status: 404, path: path} = conversation) do
    IO.puts("Tracking: #{conversation.path}")
    conversation
  end

  def track(conversation) do
    conversation
  end

  def format_response(conversation) do
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

# GET /about

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = ElixirServer.Handler.handle(request)

IO.puts(response)
