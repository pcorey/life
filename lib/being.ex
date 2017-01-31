defmodule Being do
  use GenServer

  import Enum, only: [map: 2, filter: 2]

  @offsets [
    {-1, -1}, { 0, -1}, { 1, -1},
    {-1,  0},           { 1,  0},
    {-1,  1}, { 0,  1}, { 1,  1},
  ]

  def start_link(position) do
    GenServer.start_link(__MODULE__, position, name: {
      :via, Registry, {Being.Registry, position}
    })
  end

  def reap(process) do
    Supervisor.terminate_child(Being.Supervisor, process)
  end

  def sow(position) do
    Supervisor.start_child(Being.Supervisor, [position])
  end

  def tick(process) do
    GenServer.call(process, {:tick})
  end

  def count_neighbors(process) do
    GenServer.call(process, {:count_neighbors})
  end

  def lookup(position) do
    Being.Registry
    |> Registry.lookup(position)
    |> Enum.map(fn
      {pid, _valid} -> pid
      nil -> nil
    end)
    |> Enum.filter(&Process.alive?/1)
    |> List.first
  end

  ###

  def handle_call({:tick}, _from, position) do
    to_reap = position
    |> do_count_neighbors
    |> case do
         2 -> []
         3 -> []
         _ -> [self()]
       end

    to_sow = position
    |> neighboring_positions
    |> keep_dead
    |> keep_valid_children

    {:reply, {to_reap, to_sow}, position}
  end

  def handle_call({:count_neighbors}, _from, position) do
    {:reply, do_count_neighbors(position), position}
  end

  defp do_count_neighbors(position) do
    position
    |> neighboring_positions
    |> keep_live
    |> length
  end

  defp neighboring_positions({x, y}) do
    @offsets
    |> map(fn {dx, dy} -> {x + dx, y + dy} end)
  end

  defp keep_live(positions), do: filter(positions, &(lookup(&1) != nil))

  defp keep_dead(positions), do: filter(positions, &(lookup(&1) == nil))

  defp keep_valid_children(position) do
    position
    |> filter(&(do_count_neighbors(&1) == 3))
  end

end
