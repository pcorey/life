defmodule Interface.LifeChannel do
  use Phoenix.Channel

  def join("life", _, socket) do
    Cell.Supervisor.children
    |> Enum.map(&Cell.reap/1)

    Pattern.diehard(20, 20)
    |> Enum.map(&Cell.sow/1)

    {:ok, %{positions: Cell.Supervisor.positions}, socket}
  end

  def handle_in("tick", _, socket) do
    Universe.tick

    broadcast!(socket, "tick", %{positions: Cell.Supervisor.positions})

    {:noreply, socket}
  end

end
