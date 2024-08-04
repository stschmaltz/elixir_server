defmodule ElixirServer.Plugins do
  alias ElixirServer.Conversation

  def track(%Conversation{status: 404, path: path} = conversation) do
    IO.puts("Tracking: #{path}")
    conversation
  end

  def track(%Conversation{} = conversation) do
    conversation
  end

  def rewrite_path(%Conversation{path: "/wildlife"} = conversation) do
    %{conversation | path: "/wildthings"}
  end

  def rewrite_path(%Conversation{} = conversation) do
    conversation
  end

  def log(%Conversation{} = conversation), do: IO.inspect(conversation)
end
