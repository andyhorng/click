defmodule Click.Game.Board do
  use Agent
  alias Click.Game.Board

  defstruct guests: %{}

  def start_link(game_id) do
    Agent.start_link(fn -> %Board{} end, name: via_tuple(game_id))
  end

  def via_tuple(game_id) do
    {:via, Registry, {Click.Game.BoardRegistry, game_id}}
  end

  def join(game_id, guest_id, name) do
    board = case Registry.lookup(Click.Game.BoardRegistry, game_id) do
      [] ->
        {:ok, pid} = Board.start_link(game_id)
        pid
      [{pid, _} | _rest] -> pid
    end

    Agent.update board, fn (%{guests: guests} = board) -> %{board | guests: Map.put(guests, guest_id, %{name: name, count: 0})} end
  end

  def get_guest_data(board, guest_id) do
    Agent.get board, fn %{guests: guests} -> Map.get(guests, guest_id) end
  end

  def handle_click(board, guest_id) do
    Agent.update board, fn %{guests: guests} = board ->
      %{board | guests: Map.update!(guests, guest_id, fn %{count: count} = guest -> %{guest | count: count + 1} end) } end
  end


  def get_total_clicks(board) do
    Agent.get board, fn %{guests: guests} ->
      guests |> Map.values |> Enum.map(fn %{count: count} -> count end) |> Enum.sum
    end
  end

  def fetch_all_guests(board) do
    Agent.get board, fn %{guests: guests} -> guests end
  end

  def start_over(board) do
    Agent.update board, fn (%{guests: guests} = state) ->
      %{state | guests: Enum.map(guests, fn {gid, guest} -> {gid, %{guest | count: 0}} end) |> Enum.into(%{})}
    end
  end

end
