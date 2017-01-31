defmodule UniverseTest do
  use ExUnit.Case
  doctest Universe

  setup do
    on_exit fn ->
      Being.Supervisor.children
      |> Enum.map(&Being.reap/1)
    end
    :ok
  end

  defp assert_iteration(iteration) do
    Universe.tick

    expected = iteration
    |> Enum.sort

    actual = Being.Supervisor.children
    |> Enum.map(&(Registry.keys(Being.Registry, &1)))
    |> List.flatten
    |> Enum.sort

    assert expected == actual
  end

  defp test_iterations(iterations) do
    iterations
    |> hd
    |> Enum.map(&Being.sow/1)

    iterations
    |> tl
    |> Enum.map(&assert_iteration/1)
  end

  test "counts neighbors" do
    [
      {-1, 0},
      {0, 0},
      {1, 0}
    ]
    |> Enum.map(&Being.sow/1)

    neighbors = Being.count_neighbors(Being.lookup({0, 0}))
    assert neighbors == 2
  end

  test "block" do
    [
      [
        {0, 1}, {1, 1},
        {0, 0}, {1, 0}
      ],
      [
        {0, 1}, {1, 1},
        {0, 0}, {1, 0}
      ]
    ]
    |> test_iterations
  end

  test "spinner" do
    [
      [
        {-1, 0}, {0, 0}, {1, 0}
      ],
      [
        {0,-1},
        {0, 0},
        {0, 1}
      ],
      [
        {-1, 0}, {0, 0}, {1, 0}
      ],
    ]
    |> test_iterations
  end

  test "glider" do
    [
      [
                {1, 2},
                        {2, 1},
        {0, 0}, {1, 0}, {2, 0},
      ],
      [
        {0, 1},         {2, 1},
                {1, 0}, {2, 0},
                {1,-1},
      ],
      [
                        {2, 1},
        {0, 0},         {2, 0},
                {1,-1}, {2,-1},
      ],
      [
                {1, 1},
                        {2, 0}, {3, 0},
                {1,-1}, {2,-1},
      ],
      [
                        {2, 1},
                                {3, 0},
                {1,-1}, {2,-1}, {3,-1}
      ],
    ]
    |> test_iterations
  end

end
