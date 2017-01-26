defmodule Life.Universe do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def tick do
    GenServer.call(__MODULE__, {:tick})
  end

  def spawn(x, y) do
    GenServer.call(__MODULE__, {:spawn, {x, y}})
  end

  def handle_call({:spawn, {x, y}}, _from, []) do
    Life.CellSupervisor.spawn(x, y)
    {:reply, :ok, []}
  end

  def reap([]), do: :ok
  def reap([cell | rest]) do
    IO.puts("reaping #{inspect cell}")
    Supervisor.terminate_child(Life.CellSupervisor, cell)
    reap(rest)
  end

  def sow([]), do: :ok
  def sow([{x, y} | rest]) do
    # process attempted to call itself
    # Life.Universe.spawn(x, y)
    IO.puts("sowing #{x}, #{y}")
    Life.CellSupervisor.spawn(x, y)
    sow(rest)
  end

  def reap_and_sow({reap, sow}) do
    reap(reap)
    sow(sow)
    :ok
  end

  def handle_call({:tick}, _from, []) do
    :global.registered_names
    |> Enum.map(&:global.whereis_name/1)
    |> Enum.map(&Life.Cell.tick/1)
    |> Enum.reduce({[], []}, fn
      ({to_kill, children}, {acc_to_kill, acc_children}) -> {acc_to_kill ++ to_kill, acc_children ++ children}
    end)
    |> reap_and_sow
    {:reply, :ok, []}
  end

end
