defmodule ElixirServer.Handler do
  @moduledoc """
  This module handles the request and response of the server.
  """

  import ElixirServer.Plugins, only: [log: 1, rewrite_path: 1, track: 1]
  import ElixirServer.Parser, only: [parse: 1]

  alias ElixirServer.Conversation
  alias ElixirServer.BearController

  @pages_path Path.expand("../../pages", __DIR__)

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
    BearController.index(conversation)
  end

  def route(%Conversation{method: "GET", path: "/api/bears"} = conversation) do
    ElixirServer.Api.BearController.index(conversation)
  end

  def route(%Conversation{method: "GET", path: "/bears/" <> id} = conversation) do
    params = Map.put(conversation.params, "id", id)

    BearController.show(conversation, params)
  end

  def route(%Conversation{method: "POST", path: "/bears", params: params} = conversation) do
    BearController.create(conversation, params)
  end

  def route(%Conversation{method: "GET", path: "/hibernate/" <> time} = conversation) do
    time |> String.to_integer() |> :timer.sleep()

    %{conversation | status: 200, resp_body: "Awake!"}
  end

  def route(%Conversation{method: "GET", path: "/kaboom"} = conversation) do
    raise "Kaboom!"
  end

  def route(%Conversation{method: "GET", path: "/about"} = conversation) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conversation)
  end

  def route(%Conversation{path: path} = conversation) do
    %{conversation | resp_body: "Route not found #{path}", status: 404}
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
    HTTP/1.1 #{Conversation.full_status(conversation)}\r
    Content-Type: #{conversation.resp_content_type}\r
    Content-Length: #{conversation.resp_body |> String.length()}\r
    \r
    #{conversation.resp_body}
    """
  end
end
