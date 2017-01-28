defmodule UniverseTest do
  use ExUnit.Case
  doctest Universe

  setup do
    {:ok, _} = Universe.Supervisor.start_link
    {:ok, %{}}
  end

  # test "counts neighbors", %{} do
  #   [
  #     {-1, 0},
  #     {0, 0},
  #     {1, 0}
  #   ]
  #   |> Enum.map(&Being.sow/1)

  #   neighbors = Being.count_neighbors(:global.whereis_name({:cell, 0, 0}))
  #   assert neighbors == 2
  # end

  test "creates a spinner", %{} do
    [
      {-1, 0},
      {0, 0},
      {1, 0}
    ]
    |> Enum.map(&Being.sow/1)

    beings = :global.registered_names
    |> Enum.sort()
    assert beings == [
      {:cell, -1, 0},
      {:cell, 0, 0},
      {:cell, 1, 0},
    ]

    Universe.tick

    beings = :global.registered_names
    |> Enum.sort()
    assert beings == [
      {:cell, 0, -1},
      {:cell, 0, 0},
      {:cell, 0, 1},
    ]

    Universe.tick

    beings = :global.registered_names
    |> Enum.sort()
    assert beings == [
      {:cell, -1, 0},
      {:cell, 0, 0},
      {:cell, 1, 0},
    ]
  end

  # test "creates another spinner", %{} do
  #   [
  #     {0, 0},
  #     {1, 0},
  #     {2, 0}
  #   ]
  #   |> Enum.map(&Being.sow/1)

  #   beings = :global.registered_names
  #   |> Enum.sort()
  #   assert beings == [
  #     {:cell, 0, 0},
  #     {:cell, 1, 0},
  #     {:cell, 2, 0},
  #   ]

  #   Universe.tick

  #   beings = :global.registered_names
  #   |> Enum.sort()
  #   assert beings == [
  #     {:cell, 1, -1},
  #     {:cell, 1, 0},
  #     {:cell, 1, 1},
  #   ]

  #   Universe.tick

  #   beings = :global.registered_names
  #   |> Enum.sort()
  #   assert beings == [
  #     {:cell, 0, 0},
  #     {:cell, 1, 0},
  #     {:cell, 2, 0},
  #   ]
  # end

end
