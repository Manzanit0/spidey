defmodule Spidey.Crawler.Queue do
  use Agent

  alias __MODULE__

  def start_link(urls, pool_name) do
    queue = :queue.from_list(urls)
    Agent.start_link(fn -> queue end, name: queue_name(pool_name))
  end

  def child_spec(pool_name, urls \\ []) do
    %{
      id: queue_name(pool_name),
      start: {Queue, :start_link, [urls, pool_name]}
    }
  end

  def pop(pool_name) do
    Agent.get_and_update(queue_name(pool_name), &pop_value/1)
  end

  def take(n, pool_name) do
    Agent.get_and_update(queue_name(pool_name), &pop_multiple(&1, n))
  end

  def push(url, pool_name) do
    Agent.update(queue_name(pool_name), &:queue.in(url, &1))
  end

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

  def length(pool_name) do
    queue = Agent.get(queue_name(pool_name), & &1)
    :queue.len(queue)
  end

  defp queue_name(pool_name), do: :"#{pool_name}Queue"
end
