defmodule ElixirServer.PledgeController do
  alias ElixirServer.PledgeServer

  def create(conversation, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{conversation | status: 201, resp_body: "#{name} pledged #{amount}!"}
  end

  def index(conversation) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()

    %{conversation | status: 200, resp_body: inspect(pledges)}
  end
end
