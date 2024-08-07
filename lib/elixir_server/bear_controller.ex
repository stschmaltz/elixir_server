defmodule ElixirServer.BearController do
  alias ElixirServer.Wildthings
  alias ElixirServer.Bear

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  def index(conversation) do
    bears =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_hibernating?/1)
      |> Enum.sort(&Bear.order_by_name/2)
      |> Enum.map(&bear_item/1)
      |> Enum.join()

    %{conversation | resp_body: "<ul>#{bears}</ul>", status: 200}
  end

  def show(conversation, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    %{conversation | resp_body: "<h1>Bear #{bear.id}: #{bear.name}</h1>", status: 200}
  end

  def create(conversation, %{"name" => name, "type" => type}) do
    %{
      conversation
      | resp_body: "Created a #{type} bear named #{name}!",
        status: 201
    }
  end
end
