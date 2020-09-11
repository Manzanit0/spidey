defmodule Spidey.Storage.Queue do
  use Agent

  def start_link(urls, pool_name) do
    queue = :queue.from_list(urls)
    Agent.start_link(fn -> queue end, name: queue_name(pool_name))
  end

  def child_spec(pool_name, urls \\ []) do
    %{
      id: queue_name(pool_name),
      start: {Spidey.Storage.Queue, :start_link, [urls, pool_name]}
    }
  end

  def pop(pool_name) do
    queue = Agent.get(queue_name(pool_name), & &1)
    {value, queue} = pop_value(queue)
    Agent.update(pool_name, fn _ -> queue end)
    value
  end

  def take(n, pool_name) do
    queue = Agent.get(queue_name(pool_name), & &1)

    {queue, elems} = pop_multiple(queue, n)
    Agent.update(queue_name(pool_name), fn _ -> queue end)
    elems
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

  defp pop_multiple(queue, 0, elems), do: {queue, elems}

  defp pop_multiple(queue, n, elems) do
    case :queue.out(queue) do
      {{:value, value}, queue} -> pop_multiple(queue, n - 1, [value | elems])
      {:empty, queue} -> {queue, elems}
    end
  end

  def length(pool_name) do
    queue = Agent.get(queue_name(pool_name), & &1)
    :queue.len(queue)
  end

  defp queue_name(pool_name), do: :"#{pool_name}Queue"
end
