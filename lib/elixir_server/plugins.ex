defmodule ElixirServer.Plugins do
  alias ElixirServer.Conversation

  def track(%Conversation{status: 404, path: path} = conversation) do
    if Mix.env() != :test do
      IO.puts("Tracking: #{path}")
    end

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

  def log(%Conversation{} = conversation) do
    if Mix.env() != :test do
      IO.inspect(conversation)
    end

    conversation
  end
end
