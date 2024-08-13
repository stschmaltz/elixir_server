defmodule ElixirServer.PledgeServer do
  @process_name :pledge_server

  # Client Interface

  def start do
    IO.puts("Starting the pledge server...")
    pid = spawn(__MODULE__, :listen_loop, [[]])
    Process.register(pid, @process_name)

    pid
  end

  def create_pledge(name, amount) do
    send(@process_name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} -> status
    end
  end

  def recent_pledges do
    send(@process_name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  # Server

  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, new_pledge_id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]

        send(sender, {:response, new_pledge_id})

        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected messaged: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  defp send_pledge_to_service do
    # CODE GOES HERE TO SEND A REQUEST TO THE EXTERNAL API
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
