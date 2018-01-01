defmodule ClickWeb.GameController do
  use ClickWeb, :controller
  alias Ecto.UUID
  alias Click.Guest

  def welcome(conn, %{ "id" => id}) do
    render conn, "welcome.html", id: id
  end

  def login(conn, %{"id" => id, "name" => name}) do
    # create guest
    guest_id = UUID.cast!(UUID.bingenerate())
    Guest.start_link(name, guest_id)
    redirect(conn, to: game_path(conn, :click, id, guest_id))
  end

  def click(conn, %{"id" => id, "gid" => guest_id}) do
    guest = {:via, Registry, {Click.Guest.Registry, guest_id}}
    %{name: name} = Agent.get(guest, fn s -> s end)
    conn = put_gon(conn, gid: guest_id, id: id, name: name)
    render conn, "click.html", name: name
  end
end
