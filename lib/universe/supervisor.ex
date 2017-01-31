defmodule Universe.Supervisor do
  use Supervisor

  def start(_type, _args) do
    start_link
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Universe, []),
      supervisor(Being.Supervisor, []),
      supervisor(Registry, [:unique, Being.Registry])
    ]
    supervise(children, strategy: :one_for_one)
  end

end
