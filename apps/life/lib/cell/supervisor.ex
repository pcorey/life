defmodule Cell.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(Cell, [])
    ]
    supervise(children, strategy: :simple_one_for_one, restart: :transient)
  end

  def children do
    Cell.Supervisor
    |> Supervisor.which_children
    |> Enum.map(fn
      {_, pid, _, _} -> pid
    end)
  end

  def positions do
    children()
    |> Enum.map(&Cell.position/1)
    |> Enum.map(fn {x, y} -> %{x: x, y: y} end)
  end

end
