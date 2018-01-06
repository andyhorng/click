defmodule ClickWeb.GuestChannel do
  use ClickWeb, :channel
  alias Click.Game.Board

  def join("guest:lobby", _payload, socket) do
    {:ok, socket}
  end

  def join("guest:" <> id, _payload, socket) do
    {:ok, %{test: id}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("click", payload, socket) do
    board = Board.via_tuple(payload["game_id"])
    Board.handle_click board, payload["gid"]
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (guest:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

end
