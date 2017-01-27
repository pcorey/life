defmodule Life.Cell do
  use GenServer

  def start_link({x, y}) do
    GenServer.start_link(__MODULE__, {x, y}, name: {:global, {:cell, x, y}})
  end

  def tick(cell) do
    GenServer.call(cell, {:tick})
  end

  def count_neighbors({x, y}) do
    lookup = fn ({dx, dy}) -> :global.whereis_name({:cell, x + dx, y + dy}) end
    [
      {-1, -1}, { 0, -1}, { 1, -1},
      {-1,  0},           { 1,  0},
      {-1,  1}, { 0,  1}, { 1,  1},
    ]
    |> Enum.map(lookup)
    |> Enum.reduce(0, fn
      (:undefined, neighbors) -> neighbors
      (_, neighbors) -> neighbors + 1
    end)
  end

  def who_to_kill(neighbors) when neighbors < 2, do: [self()]
  def who_to_kill(neighbors) when neighbors > 3, do: [self()]
  def who_to_kill(_neighbors), do: []

  def get_dead_neighbors({x, y}) do
    lookup = fn ({dx, dy}) -> :global.whereis_name({:cell, x + dx, y + dy}) end
    [
      {-1, -1}, { 0, -1}, { 1, -1},
      {-1,  0},           { 1,  0},
      {-1,  1}, { 0,  1}, { 1,  1},
    ]
    |> Enum.map(fn
      {dx, dy} -> {x + dx, y + dy}
    end)
    |> Enum.filter(fn
      pos -> lookup.(pos) == :undefined
    end)
  end

  def get_children({x, y}) do
    {x, y}
    |> get_dead_neighbors
    |> Enum.filter(fn (pos) -> Life.Cell.count_neighbors(pos) == 3 end)
  end

  def handle_call({:tick}, _from, {x, y}) do
    IO.puts("ticking on #{x}, #{y}")

    children = get_children({x, y})

    to_kill = {x, y}
    |> count_neighbors
    |> who_to_kill

    # IO.puts("fate: #{inspect to_kill}")
    # IO.puts("children: #{inspect children}")

    {:reply, {to_kill, children}, {x, y}}
  end

end
