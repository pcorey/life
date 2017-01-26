defmodule Life.Universe do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :universe)
  end

  def tick do
    GenServer.call(:universe, {:tick})
  end

  def handle_call({:tick}, _from, state) do
    {:reply, :ok, state}
  end

end
