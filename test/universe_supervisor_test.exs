defmodule UniverseSupervisorTest do
  use ExUnit.Case
  doctest Universe.Supervisor

  setup do
    {:ok, supervisor} = Universe.Supervisor.start_link
    {:ok, %{supervisor: supervisor}}
  end

  test "the universe is started", %{supervisor: _supervisor} do
    assert Process.whereis(Universe)
  end

  test "the universe is restarted", %{supervisor: _supervisor} do
    Process.whereis(Universe)
    |> Process.exit(:kill)

    assert Process.whereis(Universe)
  end
end
