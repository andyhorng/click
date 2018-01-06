defmodule ClickWeb.GameController do
  use ClickWeb, :controller
  alias Ecto.UUID

  def welcome(conn, %{ "id" => id}) do
    render conn, "welcome.html", id: id
  end

  def join(conn, %{"id" => id, "name" => _name}) do
    guest_id = UUID.cast!(UUID.bingenerate())
    redirect(conn, to: game_path(conn, :click, id, guest_id))
  end

  def click(conn, %{"id" => id, "gid" => guest_id}) do
    conn = put_gon(conn, gid: guest_id, id: id)
    render conn, "click.html"
  end
end
