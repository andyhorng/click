defmodule Click.Guest do
  use Agent
  alias Click.Guest

  defstruct name: nil, id: nil, clicks: 0

  def start_link(name, guest_id) do
    Agent.start_link(fn -> %Guest{name: name, id: guest_id} end, name: {:via, Registry, {Click.Guest.Registry, guest_id}})
  end

  def inc(guest) do
    Agent.update guest, fn (%Guest{clicks: clicks} = state) -> Map.put(state, :clicks, clicks + 1) end
  end
end
