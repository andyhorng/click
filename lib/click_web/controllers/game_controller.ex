defmodule ClickWeb.GameController do
  use ClickWeb, :controller
  alias Ecto.UUID
  alias Click.Game.Board

  def welcome(conn, %{ "id" => id}) do
    render conn, "welcome.html", id: id
  end

  def join(conn, %{"id" => id, "name" => name}) do
    guest_id = UUID.cast!(UUID.bingenerate())
    Board.join(id, guest_id, name)
    redirect(conn, to: game_path(conn, :click, id, guest_id))
  end

  def click(conn, %{"id" => id, "gid" => guest_id}) do
    %{name: name} = Board.get_guest_data(Board.via_tuple(id), guest_id)
    conn = put_gon(conn, gid: guest_id, id: id, name: name)
    render conn, "click.html"
  end

  def board(conn, %{"id" => id}) do
    Board.start_link(id)
    conn = put_gon(conn, id: id)
    render conn, "board.html"
  end

end
