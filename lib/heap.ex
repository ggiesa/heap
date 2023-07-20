defmodule Heap do
  @type t :: %__MODULE__{
          data: Tuple.t(number() | any(), list()),
          size: integer(),
          comparator: atom() | function()
        }

  defstruct data: nil, size: nil, comparator: nil

  @spec new_max :: Heap.t()
  def new_max(), do: new(:max)

  @spec new_min() :: Heap.t()
  def new_min(), do: new(:min)

  @spec new(atom() | function()) :: Heap.t()
  def new(comparator), do: %__MODULE__{data: nil, size: 0, comparator: comparator}

  @spec put(Heap.t(), list() | any()) :: Heap.t()
  def put(heap, []), do: heap
  def put(heap, [el | rest]), do: put(put(heap, el), rest)

  def put(%{comparator: comparator}, el) when not is_number(el) and not is_function(comparator) do
    raise ArgumentError,
      message: "Unsupported non-numerical value #{inspect(el)} for min/max heap"
  end

  def put(heap, el),
    do: %{heap | data: meld(heap.data, {el, []}, heap.comparator), size: heap.size + 1}

  @spec pop(Heap.t()) :: Tuple.t(Heap.t(), any())
  def pop(heap = %{size: 0}), do: {heap, nil}

  def pop(heap = %{data: {val, l}}),
    do: {%{heap | data: merge(l, heap.comparator), size: heap.size - 1}, val}

  @spec from_list(list(), atom() | function()) :: Heap.t()
  def from_list(l, comparator), do: put(new(comparator), l)

  @spec to_list(Heap.t()) :: list()
  def to_list(heap), do: do_to_list(heap, [])

  defp do_to_list(%{size: 0}, acc), do: Enum.reverse(acc)

  defp do_to_list(heap, acc) do
    {heap, val} = pop(heap)
    do_to_list(heap, [val | acc])
  end

  defp meld(nil, h2, _), do: h2
  defp meld(h1, nil, _), do: h1

  defp meld(h1 = {v1, l1}, h2 = {v2, l2}, comparator) when is_function(comparator) do
    if comparator.(v1, v2), do: {v1, [h2 | l1]}, else: {v2, [h1 | l2]}
  end

  defp meld({v1, l1}, h2 = {v2, _}, :min) when v1 < v2, do: {v1, [h2 | l1]}
  defp meld(h1, {v2, l2}, :min), do: {v2, [h1 | l2]}

  defp meld({v1, l1}, h2 = {v2, _}, :max) when v1 > v2, do: {v1, [h2 | l1]}
  defp meld(h1, {v2, l2}, :max), do: {v2, [h1 | l2]}

  defp merge([], _), do: nil
  defp merge([h], _), do: h

  defp merge([h1 | [h2 | rest]], comparator),
    do: meld(meld(h1, h2, comparator), merge(rest, comparator), comparator)
end
