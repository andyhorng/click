defmodule ClickWeb.GuestChannel do
  use ClickWeb, :channel

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

  def handle_in("click", %{"gid" => gid} = payload, socket) do
    guest = {:via, Registry, {Click.Guest.Registry, gid}}
    Agent.update guest, fn (%{clicks: clicks} = state) -> %{state | clicks: clicks + 1}  end
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (guest:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

end
