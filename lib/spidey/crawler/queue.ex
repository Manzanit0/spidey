defmodule Spidey.Crawler.Queue do
  use Agent

  @spec start_link(list(), atom()) :: Agent.on_start()
  def start_link(urls, name) do
    queue = :queue.from_list(urls)
    Agent.start_link(fn -> queue end, name: queue_name(name))
  end

  @spec child_spec(atom(), list()) :: map()
  def child_spec(name, urls \\ []) do
    %{
      id: queue_name(name),
      start: {__MODULE__, :start_link, [urls, name]}
    }
  end

  @spec pop(atom()) :: any()
  def pop(name) do
    Agent.get_and_update(queue_name(name), &pop_value/1)
  end

  @spec take(integer(), atom()) :: list()
  def take(n, name) do
    Agent.get_and_update(queue_name(name), &pop_multiple(&1, n))
  end

  @spec push(any(), atom()) :: :ok
  def push(url, name) do
    Agent.update(queue_name(name), &:queue.in(url, &1))
  end

  @spec length(atom()) :: integer()
  def length(name) do
    queue = Agent.get(queue_name(name), & &1)
    :queue.len(queue)
  end

  ## Private.

  defp pop_value(queue) do
    case :queue.out(queue) do
      {{:value, value}, queue} -> {value, queue}
      {:empty, queue} -> {:empty, queue}
    end
  end

  defp pop_multiple(queue, n, elems \\ [])

  defp pop_multiple(queue, 0, elems), do: {elems, queue}

  defp pop_multiple(queue, n, elems) do
    case :queue.out(queue) do
      {{:value, value}, queue} -> pop_multiple(queue, n - 1, [value | elems])
      {:empty, queue} -> {elems, queue}
    end
  end

  defp queue_name(name), do: :"#{name}Queue"
end
