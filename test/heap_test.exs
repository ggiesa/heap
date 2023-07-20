defmodule HeapTest do
  use ExUnit.Case
  doctest Heap

  test "assert min order" do
    vals = for _ <- 1..100, do: Enum.random(1..100)
    h = Heap.from_list(vals, :min)

    assert h.size == length(vals)
    assert h.comparator == :min
    assert Heap.to_list(h) == Enum.sort(vals)
  end

  test "assert max order" do
    vals = for _ <- 1..100, do: Enum.random(1..100)
    h = Heap.from_list(vals, :max)

    assert h.size == length(vals)
    assert h.comparator == :max
    assert Heap.to_list(h) == Enum.sort(vals, :desc)
  end

  test "assert custom comparator ordering" do
    vals = for _ <- 1..100, do: {Enum.random(1..100), "some data"}
    fun = fn {rank1, _}, {rank2, _} -> rank1 > rank2 end

    h = Heap.from_list(vals, fun)
    assert h.size == length(vals)
    assert h.comparator == fun
    assert Heap.to_list(h) == Enum.sort(vals, fun)
  end

  test "edge cases" do
    h1 = Heap.new_min()
    h2 = Heap.new_max()

    assert h1 == %Heap{data: nil, size: 0, comparator: :min}
    assert Heap.pop(h1) == {h1, nil}
    assert Heap.pop(h2) == {h2, nil}
    assert_raise ArgumentError, fn -> Heap.put(h1, nil) end
  end
end
