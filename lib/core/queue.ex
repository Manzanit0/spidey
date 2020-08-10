defmodule Spidey.Core.Queue do
  use Agent

  def start_link(urls) do
    queue = :queue.from_list(urls)
    Agent.start_link(fn -> queue end, name: __MODULE__)
  end

  def pop do
    queue = Agent.get(__MODULE__, & &1)
    {value, queue} = pop_value(queue)
    Agent.update(__MODULE__, fn _ -> queue end)
    value
  end

  def take(n) do
    queue = Agent.get(__MODULE__, & &1)

    # d = DateTime.utc_now()
    # IO.inspect("#{d.hour}:#{d.minute}:#{d.second} Queue size pre-take: #{:queue.len(queue)}")

    {queue, elems} = pop_multiple(queue, n)
    Agent.update(__MODULE__, fn _ -> queue end)
    elems
  end

  def push(url) do
    Agent.update(__MODULE__, &:queue.in(url, &1))
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
end
