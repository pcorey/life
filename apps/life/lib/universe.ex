defmodule Universe do
  use GenServer

  import Enum, only: [map: 2, reduce: 3]

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def tick do
    GenServer.call(__MODULE__, {:tick}, 6000000)
  end

  ###

  def handle_call({:tick}, _from, []) do
    get_cells()
    |> tick_each_process
    |> wait_for_ticks
    |> reduce_ticks
    |> reap_and_sow
    {:reply, :ok, []}
  end

  defp get_cells, do: Cell.Supervisor.children

  defp tick_each_process(processes) do
    map(processes, &(Task.async(fn -> Cell.tick(&1) end)))
  end

  defp wait_for_ticks(asyncs) do
    map(asyncs, &Task.await/1)
  end

  defp reduce_ticks(ticks), do: reduce(ticks, {[], []}, &accumulate_ticks/2)

  defp accumulate_ticks({reap, sow}, {acc_reap, acc_sow}) do
    {acc_reap ++ reap, acc_sow ++ sow}
  end

  defp reap_and_sow({to_reap, to_sow}) do
    map(to_reap, &Cell.reap/1)
    map(to_sow,  &Cell.sow/1)
  end

end
