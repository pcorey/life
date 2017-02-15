defmodule Interface.LifeChannel do
  use Phoenix.Channel

  def join("life", _, socket) do
    Cell.Supervisor.children
    |> Enum.map(&Cell.reap/1)

    Pattern.diehard(20, 20)
    |> Enum.map(&Cell.sow/1)

    positions = Cell.Supervisor.positions
    |> Enum.map(fn
      {x, y} -> %{x: x, y: y}
    end)

    {:ok, %{positions: positions}, socket}
  end

  def handle_in("tick", _, socket) do
    Universe.tick

    positions = Cell.Supervisor.positions
    |> Enum.map(fn
      {x, y} -> %{x: x, y: y}
    end)

    broadcast!(socket, "tick", %{positions: positions})

    {:noreply, socket}
  end

end
