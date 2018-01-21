defmodule ClickWeb.GuestChannel do
  use ClickWeb, :channel
  alias Click.Game.Board
  alias ClickWeb.Presence

  def join("guest:lobby", payload, socket) do
    board = Board.via_tuple(payload["game_id"])
    if payload["guest_id"] do
      guest_data = Board.get_guest_data(board, payload["guest_id"])
      send(self(), :after_join)
      {:ok, %{clicks: guest_data.count}, assign(socket, :guest_id, payload["guest_id"])}
    else
      send(self(), :after_join)
      {:ok, socket}
    end
  end

  def join("guest:board:" <> game_id, _payload, socket) do
    board = Board.via_tuple(game_id)
    {:ok, %{game_id: game_id, total: Board.get_total_clicks(board)}, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track(socket, Map.get(socket.assigns, :guest_id, "__x__"), %{online_at: inspect(System.system_time(:seconds))})
    {:noreply, socket}
  end

  def handle_info({:push_sum, board}, socket) do
    push socket, "sum", Board.fetch_all_guests(board)
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("pull_sum", payload, socket) do
    board = Board.via_tuple(payload["game_id"])
    send(self(), {:push_sum, board})
    {:noreply, socket}
  end



  def handle_in("start_over", payload, socket) do
    board = Board.via_tuple(payload["game_id"])
    Board.start_over(board)
    ClickWeb.Endpoint.broadcast! "guest:lobby", "reset", %{game_id: payload["game_id"]}
    {:noreply, socket}
  end

  def handle_in("click", payload, socket) do
    board = Board.via_tuple(payload["game_id"])
    Board.handle_click board, payload["gid"]
    ClickWeb.Endpoint.broadcast! "guest:board:#{payload["game_id"]}", "click", %{}
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (guest:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

end
