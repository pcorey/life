defmodule Universe.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Universe, []),
      supervisor(Being.Supervisor, [])
    ]
    supervise(children, strategy: :one_for_one)
  end

end
