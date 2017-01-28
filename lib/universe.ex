defmodule Universe do
  use GenServer

  import Enum, only: [map: 2, reduce: 2]

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def tick do
    GenServer.call(__MODULE__, {:tick})
  end

  ###

  def handle_call({:tick}, _from, []) do
    get_being_names()
    |> lookup_being_processes
    |> tick_each_process
    |> reduce_ticks
    |> reap_and_sow
    {:reply, :ok, []}
  end

  defp get_being_names, do: :global.registered_names

  defp lookup_being_processes(names), do: map(names, &:global.whereis_name/1)

  defp tick_each_process(processes), do: map(processes, &Being.tick/1)

  defp reduce_ticks(ticks), do: reduce(ticks, &accumulate_ticks/2)

  defp accumulate_ticks({reap, sow}, {acc_reap, acc_sow}) do
    {acc_reap ++ reap, acc_sow ++ sow}
  end

  defp reap_and_sow({to_reap, to_sow}) do
    map(to_reap, &Being.reap/1)
    map(to_sow,  &Being.sow/1)
  end

end
