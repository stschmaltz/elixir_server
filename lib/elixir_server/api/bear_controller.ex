defmodule ElixirServer.Api.BearController do
  def index(conversation) do
    json =
      ElixirServer.Wildthings.list_bears()
      |> Poison.encode!()

    %{conversation | resp_body: json, resp_content_type: "application/json", status: 200}
  end
end
