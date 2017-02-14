defmodule Pattern do

  def glider(x, y) do
    [
      {1, 2},
      {2, 1},
      {0, 0}, {1, 0}, {2, 0},
    ]
    |> Enum.map(fn
      {cx, cy} -> {x + cx, y + cy}
    end)
  end

  def diehard(x, y) do
    [
                                                      {6, 2},
      {0, 1}, {1, 1},
              {1, 0},                         {5, 0}, {6, 0}, {7, 0},
    ]
    |> Enum.map(fn
      {cx, cy} -> {x + cx, y + cy}
    end)
  end

end
