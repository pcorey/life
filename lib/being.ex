defmodule Being do
  use GenServer

  import Enum, only: [map: 2, filter: 2]

  @neighbor_offsets [
    {-1, -1}, { 0, -1}, { 1, -1},
    {-1,  0},           { 1,  0},
    {-1,  1}, { 0,  1}, { 1,  1},
  ]

  def start_link({x, y}) do
    GenServer.start_link(__MODULE__, {x, y}, name: {:global, {:cell, x, y}})
  end

  def reap(process) do
    Supervisor.terminate_child(Being.Supervisor, process)
  end

  def sow({x, y}) do
    Being.Supervisor.sow(x, y)
  end

  def tick(process) do
    GenServer.call(process, {:tick})
  end

  ###

  def handle_call({:tick}, _from, position) do
    to_reap = position
    |> count_neighbors
    |> get_to_reap

    to_sow = position
    |> get_dead_neighbors
    |> get_to_sow

    {:reply, {to_reap, to_sow}, position}
  end

  defp count_neighbors(position) do
    @neighbor_offsets
    |> neighbors(position)
    |> filter_dead
    |> length
  end

  defp neighbors(offsets, position), do: map(offsets, &(lookup(position, &1)))

  defp filter_dead(processes), do: filter(processes, &(&1 != :undefined))

  defp get_to_reap(neighbors) when neighbors < 2, do: [self()]
  defp get_to_reap(neighbors) when neighbors > 3, do: [self()]
  defp get_to_reap(_neighbors), do: []

  defp lookup({x, y}, {dx, dy}) do
    :global.whereis_name({:cell, x + dx, y + dy})
  end

  defp get_dead_neighbors({x, y}) do
    @neighbor_offsets
    |> map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> filter(&(lookup(&1, {0, 0}) == :undefined))
  end

  defp get_to_sow(neighbors), do: filter(neighbors, &(count_neighbors(&1) == 3))

end
