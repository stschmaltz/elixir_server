defmodule ElixirServer.BearController do
  alias ElixirServer.Wildthings
  alias ElixirServer.Bear
  @templates_path Path.expand("../../templates", __DIR__)

  def index(conversation) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_by_name/2)

    render_template(conversation, "index.eex", bears: bears)
  end

  def show(conversation, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render_template(conversation, "show.eex", bear: bear)
  end

  def create(conversation, %{"name" => name, "type" => type}) do
    %{
      conversation
      | resp_body: "Created a #{type} bear named #{name}!",
        status: 201
    }
  end

  defp render_template(conversation, template, bindings) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{conversation | resp_body: content, status: 200}
  end
end
