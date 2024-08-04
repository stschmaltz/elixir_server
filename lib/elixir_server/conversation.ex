defmodule ElixirServer.Conversation do
  defstruct method: "", path: "", resp_body: "", status: nil

  def full_status(conversation) do
    "#{conversation.status} #{status_reason(conversation.status)}"
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
