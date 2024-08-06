defmodule ElixirServer.Handler do
  @moduledoc """
  This module handles the request and response of the server.
  """

  import ElixirServer.Plugins, only: [log: 1, rewrite_path: 1, track: 1]
  import ElixirServer.Parser, only: [parse: 1]

  alias ElixirServer.Conversation

  @pages_path Path.expand("../pages", __DIR__)

  @doc """
  This function handles the request and response of the server.
  """
  def handle(request) do
    request
    |> parse
    |> log
    |> rewrite_path
    |> route
    |> track
    |> format_response
  end

  def route(%Conversation{method: "GET", path: "/wildthings"} = conversation) do
    %{conversation | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conversation{method: "GET", path: "/bears"} = conversation) do
    %{conversation | resp_body: "Teddy, Smokey, Paddington", status: 200}
  end

  def route(%Conversation{method: "GET", path: "/bears" <> id} = conversation) do
    %{conversation | resp_body: "Bear #{id}", status: 200}
  end

  def route(%Conversation{method: "POST", path: "/bears", params: params} = conversation) do
    %{
      conversation
      | resp_body: "Created a #{params["type"]} bear named #{params["name"]}!",
        status: 201
    }
  end

  def route(%Conversation{path: path} = conversation) do
    %{conversation | resp_body: "Route not found #{path}", status: 404}
  end

  def route(%Conversation{method: "GET", path: "/about"} = conversation) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conversation)
  end

  def handle_file({:ok, contents}, conversation) do
    %{conversation | resp_body: contents, status: 200}
  end

  def handle_file({:error, :enoent}, %Conversation{} = conversation) do
    %{conversation | resp_body: "File not found", status: 404}
  end

  def handle_file({:error, reason}, %Conversation{} = conversation) do
    %{conversation | resp_body: "File error #{reason}", status: 500}
  end

  def format_response(%Conversation{} = conversation) do
    """
    HTTP/1.1 #{Conversation.full_status(conversation)}
    Content-Type: text/html
    Content-Length: #{conversation.resp_body |> String.length()}

    #{conversation.resp_body}
    """
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

# POST /bears

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = ElixirServer.Handler.handle(request)

IO.puts(response)
