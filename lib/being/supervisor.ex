defmodule Being.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def sow(x, y) do
    Supervisor.start_child(__MODULE__, [{x, y}])
  end

  def init([]) do
    children = [
      worker(Being, [])
    ]
    supervise(children, strategy: :simple_one_for_one, restart: :transient)
  end

end
